//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Andrey Ulanov on 16.08.2023.
//

import Foundation

final class OAuth2TokenStorage {
	static let shared = OAuth2TokenStorage()
	
	private let bearerTokenKey = "bearer_token"
	
	var token: String? {
		get {
			UserDefaults.standard.string(forKey: bearerTokenKey)
		}
		set {
			UserDefaults.standard.setValue(newValue, forKey: bearerTokenKey)
		}
	}
}
