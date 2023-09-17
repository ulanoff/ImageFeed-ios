//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Andrey Ulanov on 12.08.2023.
//

import Foundation

struct OAuthTokenResponseBody: Decodable {
	let accessToken: String
	let tokenType: String
	let scope: String
	let createdAt: Int
}

final class OAuth2Service {
	private let urlSession = URLSession.shared
	private var task: URLSessionTask?
	private var lastCode: String?
	
	func fetchAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
		assert(Thread.isMainThread)
		if lastCode == code { return }
		task?.cancel()
		lastCode = code
		var request = URLRequest(url: UnsplashApiConstants.UnsplashTokenRequestURL)
		
		var body = URLComponents(url: UnsplashApiConstants.UnsplashTokenRequestURL, resolvingAgainstBaseURL: false)!
		body.queryItems = [
			URLQueryItem(name: "client_id", value: UnsplashApiConstants.AccessKey),
			URLQueryItem(name: "client_secret", value: UnsplashApiConstants.SecretKey),
			URLQueryItem(name: "redirect_uri", value: UnsplashApiConstants.RedirectURI),
			URLQueryItem(name: "code", value: code),
			URLQueryItem(name: "grant_type", value: "authorization_code")
		]
		let bodyData = body.query?.data(using: .utf8)
		
		request.httpMethod = "POST"
		request.httpBody = bodyData
		
		let task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
			guard let self else { return }
			switch result {
			case .success(let tokenData):
				let token = tokenData.accessToken
				completion(.success(token))
			case .failure(let error):
				completion(.failure(error))
				self.lastCode = nil
			}
			self.task = nil
		}
		self.task = task
		task.resume()
	}
}
