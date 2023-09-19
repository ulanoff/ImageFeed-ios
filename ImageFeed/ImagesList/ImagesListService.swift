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

struct LikedPhotoResult: Decodable {
	let photo: PhotoResult
}

struct Photo {
	let id: String
	let size: CGSize
	let createdAt: Date?
	let welcomeDescription: String?
	let thumbImageURL: String
	let largeImageURL: String
	let isLiked: Bool
	
	init(
		id: String,
		size: CGSize,
		createdAt: Date?,
		welcomeDescription: String?,
		thumbImageURL: String,
		largeImageURL: String,
		isLiked: Bool
	) {
		self.id = id
		self.size = size
		self.createdAt = createdAt
		self.welcomeDescription = welcomeDescription
		self.thumbImageURL = thumbImageURL
		self.largeImageURL = largeImageURL
		self.isLiked = isLiked
	}
	
	init(photoData: PhotoResult) {
		id = photoData.id
		size = CGSize(width: photoData.width, height: photoData.height)
		createdAt = photoData.createdAt != nil ? ISO8601DateFormatter().date(from: photoData.createdAt!) : nil
		welcomeDescription = photoData.description
		thumbImageURL = photoData.urls.thumb
		largeImageURL = photoData.urls.full
		isLiked = photoData.likedByUser
	}
	
	func changedLikeState() -> Photo {
		return Photo(id: self.id,
					 size: self.size,
					 createdAt: self.createdAt,
					 welcomeDescription: self.welcomeDescription,
					 thumbImageURL: self.thumbImageURL,
					 largeImageURL: self.largeImageURL,
					 isLiked: !self.isLiked)
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
		if task != nil { return }
		let nextPage = lastLoadedPage == nil ? 1 : lastLoadedPage! + 1
		
		guard let url = URL(string: "\(UnsplashApiConstants.DefaultBaseURL.description)/photos?page=\(nextPage)"),
			  let accessToken = OAuth2TokenStorage.shared.token
		else {
			assertionFailure("Failed to create URL or get token from storage")
			return
		}
		
		var request = URLRequest(url: url)
		request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
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
	
	func changeLike(
		photoId: String,
		isLike: Bool,
		_ completion: @escaping (Result<Void, Error>) -> Void
	) {
		if task != nil { return }
		
		guard
			let url = URL(string: "\(UnsplashApiConstants.DefaultBaseURL)/photos/\(photoId)/like"),
			let accessToken = OAuth2TokenStorage.shared.token
		else {
			assertionFailure("Failed to create URL or get token from storage")
			return
		}
		
		var request = URLRequest(url: url)
		request.httpMethod = isLike ? "POST" : "DELETE"
		request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
		let task = urlSession.objectTask(for: request) { (result: Result<LikedPhotoResult, Error>) in
			switch result {
			case .success(_):
				if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
					let photo = self.photos[index]
					let newPhoto = photo.changedLikeState()
					self.photos = self.photos.withReplaced(itemAt: index, newValue: newPhoto)
				}
				completion(.success(()))
			case .failure(let error):
				completion(.failure(error))
			}
			self.task = nil
		}
		self.task = task
		task.resume()
	}
}
