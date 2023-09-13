//
//  URLSession+Ext.swift
//  ImageFeed
//
//  Created by Andrey Ulanov on 13.09.2023.
//

import Foundation

extension URLSession {
	func objectTask<T: Decodable>(
		for request: URLRequest,
		completion: @escaping (Result<T, Error>) -> Void
	) -> URLSessionTask {
		let task = dataTask(with: request) { data, response, error in
			DispatchQueue.main.async {
				if let data,
				   let response,
				   let statusCode = (response as? HTTPURLResponse)?.statusCode
				{
					if 200..<300 ~= statusCode {
						do {
							let decoder = JSONDecoder()
							decoder.keyDecodingStrategy = .convertFromSnakeCase
							let decodedData = try decoder.decode(T.self, from: data)
							completion(.success(decodedData))
						} catch {
							completion(.failure(NetworkError.dataDecodingError))
						}
					} else {
						completion(.failure(NetworkError.httpStatusCode(statusCode)))
					}
				} else if let error {
					completion(.failure(NetworkError.urlRequestError(error)))
				} else {
					completion(.failure(NetworkError.urlSessionError))
				}
			}
		}
		return task
	}
}
