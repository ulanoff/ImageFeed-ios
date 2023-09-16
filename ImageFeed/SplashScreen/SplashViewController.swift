//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Andrey Ulanov on 16.08.2023.
//

import UIKit
import SwiftKeychainWrapper

final class SplashViewController: UIViewController {
	private let profileService = ProfileService.shared
	
	private var appLogoImage: UIImageView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		if let token = KeychainWrapper.standard.string(forKey: "Auth Token") {
			fetchProfile(code: token)
		} else {
			let authVC = AuthViewController()
			authVC.delegate = self
			authVC.modalPresentationStyle = .fullScreen
			present(authVC, animated: true)
		}
	}
	
	private func switchToTabBarController() {
		guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
		let tabBarController = TabBarController()
		window.rootViewController = tabBarController
	}
	
	private func fetchProfile(code: String) {
		profileService.fetchProfile(code) { [weak self] result in
			guard let self else { return }
			switch result {
			case .success(let profile):
				switchToTabBarController()
				fetchProfileImage(username: profile.username)
			case .failure(_):
				let alertModel = AlertModel(title: "Что-то пошло не так(",
											message: "Не удалось войти в систему",
											buttonText: "Ок",
											completion: nil)
				AlertPresenter.shared.presentAlert(in: self, with: alertModel)
			}
		}
	}
	
	private func fetchProfileImage(username: String) {
		ProfileImageService.shared.fetchProfileImageURL(username: username) { result in
			switch result {
			case .success(_):
				return
			case .failure(let error):
				assertionFailure("Failed to load avatar: \(error.localizedDescription)")
			}
		}
	}
}

private extension SplashViewController {
	func setupUI() {
		configureAppLogoImageView()
		configureMainView()
		configureConstraints()
	}
	
	func configureMainView() {
		view.backgroundColor = .ypBlack
		view.addSubview(appLogoImage)
	}
	
	func configureAppLogoImageView() {
		appLogoImage = UIImageView()
		appLogoImage.tintColor = .white
		appLogoImage.image = UIImage(named: "logo")
	}
	
	func configureConstraints() {
		appLogoImage.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			appLogoImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			appLogoImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
			appLogoImage.widthAnchor.constraint(equalToConstant: 75)
		])
	}
}

extension SplashViewController: AuthViewControllerDelegate {
	func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
		fetchProfile(code: code)
	}
}
