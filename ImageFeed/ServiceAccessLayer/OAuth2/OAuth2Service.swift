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
	func fetchAuthToken(code: String, completion: @escaping (Result<Data, Error>) -> Void) {
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
			if let data,
			   let response,
			   let statusCode = (response as? HTTPURLResponse)?.statusCode
			{
				if 200..<300 ~= statusCode {
					DispatchQueue.main.async {
						completion(.success(data))
					}
				} else {
					DispatchQueue.main.async {
						completion(.failure(NetworkError.httpStatusCode(statusCode)))
					}
				}
			}
			else if let error {
				DispatchQueue.main.async {
					completion(.failure(NetworkError.urlRequestError(error)))
				}
			} else {
				DispatchQueue.main.async {
					completion(.failure(NetworkError.urlSessionError))
				}
			}
		}
		task.resume()
	}
}
