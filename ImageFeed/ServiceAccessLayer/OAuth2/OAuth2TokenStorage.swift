//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Andrey Ulanov on 17.09.2023.
//

import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
	static let shared = OAuth2TokenStorage()
	
	private let bearerTokenKey = "bearer_token"
	
	var token: String? {
		get {
			KeychainWrapper.standard.string(forKey: bearerTokenKey)
		}
		set {
			guard let newValue else { return }
			KeychainWrapper.standard.set(newValue, forKey: bearerTokenKey)
		}
	}
	
	func deleteToken() {
		KeychainWrapper.standard.removeObject(forKey: bearerTokenKey)
	}
}
