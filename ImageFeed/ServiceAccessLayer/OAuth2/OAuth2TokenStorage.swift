//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Andrey Ulanov on 16.08.2023.
//

import Foundation

final class OAuth2TokenStorage {
	var token: String? {
		get {
			UserDefaults.standard.string(forKey: "bearer_token")
		}
		set {
			UserDefaults.standard.setValue(newValue, forKey: "bearer_token")
		}
	}
}
