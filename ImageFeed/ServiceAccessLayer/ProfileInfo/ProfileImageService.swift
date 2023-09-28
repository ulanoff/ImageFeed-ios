//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Andrey Ulanov on 12.09.2023.
//

import Foundation

struct UserResult: Codable {
	let profileImage: ProfileImage
}

struct ProfileImage: Codable {
	let small: String
}

final class ProfileImageService {
	static let shared = ProfileImageService()
	static let didChangeNotification = Notification.Name("ProfileImageProviderDidChange")
	
	private let decoder: JSONDecoder = {
		let decoder = JSONDecoder()
		decoder.keyDecodingStrategy = .convertFromSnakeCase
		return decoder
	}()
	private let urlSession = URLSession.shared
	private let authConfiguration = AuthConfiguration.standart
	private var task: URLSessionTask?
	private var lastUsername: String?
	private(set) var avatarURL: String?
	
	func fetchProfileImageURL(username: String, completion: @escaping (Result<String, Error>) -> Void) {
		assert(Thread.isMainThread)
		if lastUsername == username { return }
		task?.cancel()
		lastUsername = username
		
		guard let url = URL(string: "\(authConfiguration.defaultBaseURL)/users/\(username)"),
			  let accessToken = OAuth2TokenStorage.shared.token
		else {
			assertionFailure("Failed to create URL or get token from storage")
			return
		}
		
		var request = URLRequest(url: url)
		request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
		
		let task = urlSession.objectTask(for: request) { [weak self] (result: Result<UserResult, NetworkError>) in
			guard let self else { return }
			switch result {
			case .success(let userResult):
				let avatarURL = userResult.profileImage.small
				ProfileImageService.shared.avatarURL = avatarURL
				NotificationCenter.default
					.post(name: ProfileImageService.didChangeNotification,
						  object: self,
						  userInfo: ["URL": avatarURL])
				completion(.success(avatarURL))
			case .failure(let error):
				completion(.failure(error))
				self.lastUsername = nil
			}
			self.task = nil
		}
		self.task = task
		task.resume()
	}
}
