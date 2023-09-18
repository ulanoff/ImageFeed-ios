//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Andrey Ulanov on 18.09.2023.
//

import Foundation

struct PhotoResult: Decodable {
	let id: String
	let width: Int
	let height: Int
	let createdAt: String
	let description: String
	let urls: UrlsResult
	let likedByUser: Bool
	
	struct UrlsResult: Decodable {
		let thumb: String
		let full: String
	}
}

struct Photo {
	let id: String
	let size: CGSize
	let createdAt: Date?
	let welcomeDescription: String?
	let thumbImageURL: String
	let largeImageURL: String
	let isLiked: Bool
	
	init(photoData: PhotoResult) {
		id = photoData.id
		size = CGSize(width: photoData.width, height: photoData.height)
		createdAt = ISO8601DateFormatter().date(from: photoData.createdAt)
		welcomeDescription = photoData.description
		thumbImageURL = photoData.urls.thumb
		largeImageURL = photoData.urls.full
		isLiked = photoData.likedByUser
	}
}

final class ImagesListService {
	static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
	
	private let urlSession = URLSession.shared
	private var task: URLSessionTask?
	private(set) var photos: [Photo] = []
	private var lastLoadedPage: Int?
	
	func fetchPhotosNextPage(completion: @escaping (Result<[Photo], Error>) -> Void) {
		guard let url = URL(string: "\(UnsplashApiConstants.DefaultBaseURL.description)/photos")
		else {
			assertionFailure("Failed to create URL")
			return
		}
		
		let nextPage = lastLoadedPage == nil ? 1 : lastLoadedPage! + 1
		var request = URLRequest(url: url)
		request.setValue(nextPage.description, forHTTPHeaderField: "page")
		let task = urlSession.objectTask(for: request) { (result: Result<[PhotoResult], Error>) in
			switch result {
			case .success(let photosData):
				var photos: [Photo] = []
				for photoData in photosData {
					let photo = Photo(photoData: photoData)
					photos.append(photo)
				}
				self.photos += photos
				completion(.success(photos))
				NotificationCenter.default
					.post(name: ImagesListService.didChangeNotification,
						  object: self)
			case .failure(let error):
				completion(.failure(error))
			}
			self.task = nil
		}
		self.task = task
		task.resume()
	}
}
