//
//  ImagesListPresenter.swift
//  ImageFeed
//
//  Created by Andrey Ulanov on 27.09.2023.
//

import Foundation

protocol ImagesListPresenterProtocol {
	var view: ImagesListViewControllerProtocol? { get set }
	func viewDidLoad()
	func getImages()
	func like(photo: Photo, completion: (() -> Void)?)
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
	weak var view: ImagesListViewControllerProtocol?
	private var imageListServiceObserver: NSObjectProtocol?
	private let imagesListService = ImagesListService()
	
	func viewDidLoad() {
		setupImageListServiceObserver()
		getImages()
	}
	
	func setupImageListServiceObserver() {
		imageListServiceObserver = NotificationCenter.default
			.addObserver(
				forName: ImagesListService.didChangeNotification,
				object: nil,
				queue: .main
			) { [weak self] _ in
				guard 
					let self,
					let oldCount = view?.photos.count
				else { return }
				let newCount = imagesListService.photos.count
				view?.photos = imagesListService.photos
				if oldCount != newCount {
					let indexPaths = (oldCount..<newCount).map {
						return IndexPath(row: $0, section: 0)
					}
					self.view?.updateTableViewAnimated(at: indexPaths)
				}
			}
	}
	
	func like(photo: Photo, completion: (() -> Void)?) {
		imagesListService.changeLike(
			photoId: photo.id,
			isLike: !photo.isLiked
		) { [weak self] result in
			guard let self else { return }
			switch result {
			case .success(_):
				self.view?.setIsLiked(on: photo, isLiked: photo.isLiked)
			case .failure(_):
				let alertModel = AlertModel(title: "Что-то пошло не так(",
											message: "Не удалось оценить запись пользователя",
											buttonText: "Ок",
											completion: nil)
				self.view?.showAlert(model: alertModel)
			}
			completion?()
		}
	}
	
	func getImages() {
		imagesListService.fetchPhotosNextPage()
	}
}
