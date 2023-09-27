//
//  ImagesListViewController.swift
//  ImageFeed
//
//  Created by Andrey Ulanov on 30.06.2023.
//

import UIKit
import Kingfisher

protocol ImagesListViewControllerProtocol: AnyObject {
	var presenter: ImagesListPresenterProtocol? { get set }
	var photos: [Photo] { get set }
	func updateTableViewAnimated(at indexPaths: [IndexPath])
	func setIsLiked(on photo: Photo, isLiked: Bool)
	func showAlert(model: AlertModel)
}

final class ImagesListViewController: UIViewController, ImagesListViewControllerProtocol {
	var presenter: ImagesListPresenterProtocol?
	var photos: [Photo] = []
	
	private var tableView: UITableView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
		presenter?.viewDidLoad()
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
	
	func updateTableViewAnimated(at indexPaths: [IndexPath]) {
		tableView.performBatchUpdates {
			tableView.insertRows(at: indexPaths, with: .automatic)
		}
	}
	
	func setIsLiked(on photo: Photo, isLiked: Bool) {
		guard let cellRow = photos.firstIndex(where: { $0.id == photo.id })
		else { return }
		let indexPath = IndexPath(row: cellRow, section: 0)
		let cell = tableView.cellForRow(at: indexPath)
		if let imageCell = cell as? ImagesListCell {
			imageCell.setIsLiked(isLiked: !photo.isLiked)
		}
	}
	
	func showAlert(model: AlertModel) {
		AlertPresenter.shared.presentAlert(in: self, with: model)
	}
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
	
	func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
		cell.delegate = self
		let photo = photos[indexPath.row]
		cell.configureCell(with: photo) { [weak self] result in
			guard let self else { return }
			switch result {
			case .success(_):
				self.tableView.reloadRows(at: [indexPath], with: .automatic)
			case .failure(_):
				return
			}
		}
	}
}

extension ImagesListViewController: ImagesListCellDelegate {
	func imagesListCellDidTapLike(_ cell: ImagesListCell) {
		guard let index = tableView.indexPath(for: cell)?.row
		else { return }
		UIBlockingProgressHUD.show()
		let photo = photos[index]
		presenter?.like(photo: photo) {
			UIBlockingProgressHUD.dismiss()
		}
	}
}

extension ImagesListViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return photos.count
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

extension ImagesListViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		if indexPath.row == photos.count - 1 {
			presenter?.getImages()
		}
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let photo = photos[indexPath.row]
		guard let url = URL(string: photo.largeImageURL) else { return }
		let vc = SingleImageViewController(imageURL: url)
		vc.modalPresentationStyle = .overCurrentContext
		present(vc, animated: true)
	}
}
