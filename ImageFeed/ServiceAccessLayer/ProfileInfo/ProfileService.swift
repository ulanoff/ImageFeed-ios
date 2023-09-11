//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Andrey Ulanov on 11.09.2023.
//

import Foundation

fileprivate enum NetworkError: Error {
	case httpStatusCode(Int)
	case urlRequestError(Error)
	case urlSessionError
	case profileDecodingError
}

struct Profile {
	let username: String
	let name: String
	let loginName: String
	let bio: String?
	
	init(profileData: ProfileResult) {
		username = profileData.username ?? ""
		name = "\(profileData.firstName ?? "") \(profileData.lastName ?? "")"
		loginName = "@\(profileData.username ?? "")"
		bio = profileData.bio
	}
}

struct ProfileResult: Codable {
	let username: String?
	let firstName: String?
	let lastName: String?
	let bio: String?
}

final class ProfileService {
	static let shared = ProfileService()
	
	private let decoder: JSONDecoder = {
		let decoder = JSONDecoder()
		decoder.keyDecodingStrategy = .convertFromSnakeCase
		return decoder
	}()
	private let urlSession = URLSession.shared
	private var task: URLSessionTask?
	private var lastToken: String?
	private(set) var profile: Profile?
	
	func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
		assert(Thread.isMainThread)
		if lastToken == token { return }
		task?.cancel()
		lastToken = token
		
		guard let url = URL(string: "\(UnsplashApiConstants.DefaultBaseURL)/me") else {
			assertionFailure("Failed to create URL")
			return
		}
		
		var request = URLRequest(url: url)
		request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
		let task = urlSession.dataTask(with: request) { data, response, error in
			DispatchQueue.main.async { [weak self] in
				guard let self else { return }
				if let data,
				   let response,
				   let statusCode = (response as? HTTPURLResponse)?.statusCode
				{
					if 200..<300 ~= statusCode {
						do {
							let profileData = try self.decoder.decode(ProfileResult.self, from: data)
							let profile = Profile(profileData: profileData)
							ProfileService.shared.profile = profile
							completion(.success(profile))
						} catch {
							completion(.failure(NetworkError.profileDecodingError))
							self.lastToken = nil
						}
					} else {
						completion(.failure(NetworkError.httpStatusCode(statusCode)))
						self.lastToken = nil
					}
				} else if let error {
					completion(.failure(error))
					self.lastToken = nil
				} else {
					completion(.failure(NetworkError.urlSessionError))
					self.lastToken = nil
				}
				self.task = nil
			}
		}
		self.task = task
		task.resume()
	}
}
