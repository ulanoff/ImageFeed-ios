//
//  ViewController.swift
//  ImageFeed
//
//  Created by Andrey Ulanov on 30.06.2023.
//

import UIKit

class ImagesListViewController: UIViewController {
	private let photosName: [String] = Array(0..<20).map{ "\($0)" }
	private let showSingleImageSegueIdentifier = "ShowSingleImage"
	
	@IBOutlet private var tableView: UITableView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == showSingleImageSegueIdentifier {
			let vc = segue.destination as! SingleImageViewController
			let indexPath = sender as! IndexPath
			let image = UIImage(named: photosName[indexPath.row])
			vc.image = image
		} else {
			super.prepare(for: segue, sender: sender)
		}
	}
}

extension ImagesListViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return photosName.count
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
		guard let image = UIImage(named: photosName[indexPath.row]) else { return }
		let isEvenCell = (indexPath.row + 1) % 2 == 0
		cell.configureCell(with: image,
						   isLiked: isEvenCell,
						   date: Date())
	}
}

extension ImagesListViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		guard let image = UIImage(named: photosName[indexPath.row]) else {
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
		performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
	}
}


