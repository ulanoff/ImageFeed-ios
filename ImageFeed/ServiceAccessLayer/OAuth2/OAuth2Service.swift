//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Andrey Ulanov on 12.08.2023.
//

import Foundation

enum NetworkError: Error {
	case httpStatusCode(Int)
	case urlRequestError(Error)
	case urlSessionError
}

final class OAuth2Service {
	private let urlSession = URLSession.shared
	private var task: URLSessionTask?
	private var lastCode: String?
	
	func fetchAuthToken(code: String, completion: @escaping (Result<Data, Error>) -> Void) {
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
		
		let task = URLSession.shared.dataTask(with: request) { data, response, error in
			DispatchQueue.main.async { [weak self] in
				guard let self else { return }
				if let data,
				   let response,
				   let statusCode = (response as? HTTPURLResponse)?.statusCode
				{
					if 200..<300 ~= statusCode {
						completion(.success(data))
					} else {
						completion(.failure(NetworkError.httpStatusCode(statusCode)))
						self.lastCode = nil
					}
				}
				else if let error {
					completion(.failure(NetworkError.urlRequestError(error)))
					self.lastCode = nil
				} else {
					completion(.failure(NetworkError.urlSessionError))
					self.lastCode = nil
				}
				self.task = nil
			}
		}
		task.resume()
	}
}
