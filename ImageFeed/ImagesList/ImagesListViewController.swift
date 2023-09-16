//
//  ViewController.swift
//  ImageFeed
//
//  Created by Andrey Ulanov on 30.06.2023.
//

import UIKit

class ImagesListViewController: UIViewController {
	private let imagesNames: [String] = Array(0..<20).map{ "\($0)" }
	
	private var tableView: UITableView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
}

private extension ImagesListViewController {
	func setupUI() {
		configureTableView()
		configureMainView()
		configureConstraints()
	}
	
	func configureMainView() {
		view.addSubview(tableView)
	}
	
	func configureTableView() {
		tableView = UITableView()
		tableView.delegate = self
		tableView.dataSource = self
		tableView.register(ImagesListCell.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
		tableView.separatorStyle = .none
		tableView.backgroundColor = .ypBlack
		tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
	}
	
	func configureConstraints() {
		tableView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			tableView.topAnchor.constraint(equalTo: view.topAnchor),
			tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
		])
	}
}

extension ImagesListViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return imagesNames.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)

		guard let imageListCell = cell as? ImagesListCell else {
			assertionFailure("Couldn't dequeue reusable cell as ImageListCell")
			return UITableViewCell()
		}

		configCell(for: imageListCell, with: indexPath)

		return imageListCell
	}
}

extension ImagesListViewController {
	func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
		guard let image = UIImage(named: imagesNames[indexPath.row]) else { return }
		let isEvenCell = (indexPath.row + 1) % 2 == 0
		cell.configureCell(with: image,
						   isLiked: isEvenCell,
						   date: Date())
	}
}

extension ImagesListViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		guard let image = UIImage(named: imagesNames[indexPath.row]) else {
			return 0
		}
		let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
		let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
		let imageWidth = image.size.width
		let scale = imageViewWidth / imageWidth
		let cellHeight = image.size.height * scale + imageInsets.top + imageInsets.bottom
		return cellHeight
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let vc = SingleImageViewController()
		vc.image = UIImage(named: imagesNames[indexPath.row])
		vc.modalPresentationStyle = .overCurrentContext
		present(vc, animated: true)
	}
}


