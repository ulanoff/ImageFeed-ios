//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Andrey Ulanov on 16.08.2023.
//

import UIKit

final class SplashViewController: UIViewController {
	private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreenSegue"
	private let showGalleryScreenSegueIdentifier = "ShowGalleryScreenSegue"
	private let profileService = ProfileService.shared
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		if let token = OAuth2TokenStorage.shared.token {
			fetchProfile(code: token)
		} else {
			performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
		}
	}
	
	private func switchToTabBarController() {
		guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
		let tabBarController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "TabBarViewController")
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

extension SplashViewController {
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == showAuthenticationScreenSegueIdentifier {
			guard let navController = segue.destination as? UINavigationController,
				  let viewController = navController.viewControllers.first as? AuthViewController
			else {
				assertionFailure("Failed to prepare for ShowAuthenticationScreenSegue")
				return
			}
			viewController.delegate = self
		} else {
			super.prepare(for: segue, sender: sender)
		}
	}
}

extension SplashViewController: AuthViewControllerDelegate {
	func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
		fetchProfile(code: code)
	}
}
