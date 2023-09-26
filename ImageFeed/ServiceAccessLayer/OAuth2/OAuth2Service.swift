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
	private let authConfiguration = AuthConfiguration.standart
	private let urlSession = URLSession.shared
	private var task: URLSessionTask?
	private var lastCode: String?
	
	func fetchAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
		guard let url = URL(string: authConfiguration.tokenRequestURLString)
		else {
			assertionFailure("Failed to create URL")
			return
		}
		assert(Thread.isMainThread)
		if lastCode == code { return }
		task?.cancel()
		lastCode = code
		var request = URLRequest(url: url)
		
		var body = URLComponents(url: url, resolvingAgainstBaseURL: false)!
		body.queryItems = [
			URLQueryItem(name: "client_id", value: authConfiguration.accessKey),
			URLQueryItem(name: "client_secret", value: authConfiguration.secretKey),
			URLQueryItem(name: "redirect_uri", value: authConfiguration.redirectURI),
			URLQueryItem(name: "code", value: code),
			URLQueryItem(name: "grant_type", value: "authorization_code")
		]
		let bodyData = body.query?.data(using: .utf8)
		
		request.httpMethod = "POST"
		request.httpBody = bodyData
		
		let task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, NetworkError>) in
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
