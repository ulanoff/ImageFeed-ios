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
	let createdAt: String?
	let description: String?
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
		createdAt = photoData.createdAt != nil ? ISO8601DateFormatter().date(from: photoData.createdAt!) : nil
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
	private(set) var photos: [Photo] = [] {
		didSet {
			NotificationCenter.default
				.post(name: ImagesListService.didChangeNotification,
					  object: self)
		}
	}
	private var lastLoadedPage: Int?
	
	func fetchPhotosNextPage() {
		guard let url = URL(string: "\(UnsplashApiConstants.DefaultBaseURL.description)/photos"),
			  let accessToken = OAuth2TokenStorage.shared.token
		else {
			assertionFailure("Failed to create URL or get token from storage")
			return
		}
		
		let nextPage = lastLoadedPage == nil ? 1 : lastLoadedPage! + 1
		var request = URLRequest(url: url)
		request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
		request.addValue(nextPage.description, forHTTPHeaderField: "page")
		let task = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
			guard let self else { return }
			switch result {
			case .success(let photosData):
				var photos: [Photo] = []
				for photoData in photosData {
					let photo = Photo(photoData: photoData)
					photos.append(photo)
				}
				self.photos += photos
				self.lastLoadedPage = nextPage
			case .failure(let error):
				assertionFailure(error.localizedDescription)
			}
			self.task = nil
		}
		self.task = task
		task.resume()
	}
}
