//
//  ViewController.swift
//  ImageFeed
//
//  Created by Andrey Ulanov on 30.06.2023.
//

import UIKit
import Kingfisher

class ImagesListViewController: UIViewController {
	private let imagesListService = ImagesListService()
	private var imageListServiceObserver: NSObjectProtocol?
	private var photos: [Photo] = []
	
	private var tableView: UITableView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
		setupImageListServiceObserver()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		imagesListService.fetchPhotosNextPage()
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
}

private extension ImagesListViewController {
	func setupImageListServiceObserver() {
		imageListServiceObserver = NotificationCenter.default
			.addObserver(
				forName: ImagesListService.didChangeNotification,
				object: nil,
				queue: .main
			) { [weak self] _ in
				guard let self else { return }
				self.updateTableViewAnimated()
			}
	}
	
	func updateTableViewAnimated() {
		let oldCount = photos.count
		let newCount = imagesListService.photos.count
		photos = imagesListService.photos
		if oldCount != newCount {
			tableView.performBatchUpdates {
				let indexPaths = (oldCount..<newCount).map {
					return IndexPath(row: $0, section: 0)
				}
				tableView.insertRows(at: indexPaths, with: .automatic)
			}
		}
	}
	
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

extension ImagesListViewController {
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
		imagesListService.changeLike(photoId: photo.id,
									 isLike: !photo.isLiked) { result in
			switch result {
			case .success(_):
				cell.setIsLiked(isLiked: !photo.isLiked)
			case .failure(_):
				let alertModel = AlertModel(title: "Что-то пошло не так(",
											message: "Не удалось оценить запись пользователя",
											buttonText: "Ок",
											completion: nil)
				AlertPresenter.shared.presentAlert(in: self, with: alertModel)
			}
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
			imagesListService.fetchPhotosNextPage()
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


