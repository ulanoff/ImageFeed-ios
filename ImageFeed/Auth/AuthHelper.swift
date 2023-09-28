//
//  AuthHelper.swift
//  ImageFeed
//
//  Created by Andrey Ulanov on 26.09.2023.
//

import Foundation

protocol AuthHelperProtocol {
	func authRequest() -> URLRequest
	func code(from url: URL) -> String?
}

final class AuthHelper: AuthHelperProtocol {
	let configuration: AuthConfiguration
	
	init(configuration: AuthConfiguration = .standart) {
		self.configuration = configuration
	}
	
	func authRequest() -> URLRequest {
		let url = authURL()
		return URLRequest(url: url)
	}
	
	func authURL() -> URL {
		guard
            let url = URL(string: configuration.authURLString),
            var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)
		else {
			fatalError("Failed to create URL")
		}
		urlComponents.queryItems = [
			URLQueryItem(name: "client_id", value: configuration.accessKey),
			URLQueryItem(name: "redirect_uri", value: configuration.redirectURI),
			URLQueryItem(name: "response_type", value: configuration.responseType),
			URLQueryItem(name: "scope", value: configuration.accessScope),
		]
		return urlComponents.url!
	}
	
	func code(from url: URL) -> String? {
		if
			let urlComponents = URLComponents(string: url.absoluteString),
			urlComponents.path == "/oauth/authorize/native",
			let items = urlComponents.queryItems,
			let codeItem = items.first(where: { $0.name == configuration.responseType })
		{
			return codeItem.value
		} else {
			return nil
		}
	}
}
