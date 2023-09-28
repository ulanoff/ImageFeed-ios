//
//  ProfilePresenter.swift
//  ImageFeed
//
//  Created by Andrey Ulanov on 27.09.2023.
//

import Foundation
import WebKit

protocol ProfilePresenterProtocol {
	var view: ProfileViewControllerProtocol? { get set }
	func viewDidLoad()
	func didTapLogoutButton()
	func didConfirmLogout()
}

final class ProfilePresenter: ProfilePresenterProtocol {
	weak var view: ProfileViewControllerProtocol?
	private var profileImageServiceObserver: NSObjectProtocol?
	private let profileService = ProfileService.shared
	private let profileImageService = ProfileImageService.shared
	
	func viewDidLoad() {
		addAvatarUpdateObserver()
		updateAvatar()
		if let profile = profileService.profile {
			view?.setProfileDetails(profile: profile)
		}
	}
	
	func didTapLogoutButton() {
		view?.showLogoutAlert()
	}
	
	func addAvatarUpdateObserver() {
		profileImageServiceObserver = NotificationCenter.default
			.addObserver(forName: ProfileImageService.didChangeNotification,
						 object: nil,
						 queue: .main
			) { [weak self] _ in
				guard let self else { return }
				updateAvatar()
			}
	}
	
	func updateAvatar() {
		guard
			let profileImageURL = profileImageService.avatarURL,
			let url = URL(string: profileImageURL)
		else { return }
		view?.setAvatarImage(url: url)
	}
	
	func didConfirmLogout() {
		logout()
		view?.switchToSplashViewController()
	}
	
	func logout() {
		OAuth2TokenStorage.shared.deleteToken()
		clearCookies()
	}
	
	func clearCookies() {
		HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
		WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
			records.forEach { record in
				WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
			}
		}
	}
}
