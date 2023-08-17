//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Andrey Ulanov on 16.08.2023.
//

import UIKit

final class SplashViewController: UIViewController {
	private let ShowAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreenSegue"
	private let ShowGalleryScreenSegueIdentifier = "ShowGalleryScreenSegue"
	private let oauthTokenStorage = OAuth2TokenStorage()
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		if let _ = oauthTokenStorage.token {
			performSegue(withIdentifier: ShowGalleryScreenSegueIdentifier, sender: nil)
		} else {
			performSegue(withIdentifier: ShowAuthenticationScreenSegueIdentifier, sender: nil)
		}
	}
	
	private func switchToTabBarController() {
		guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
		let tabBarController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "TabBarViewController")
		window.rootViewController = tabBarController
	}
}

extension SplashViewController {
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == ShowAuthenticationScreenSegueIdentifier {
			guard let navController = segue.destination as? UINavigationController,
				  let viewController = navController.viewControllers[0] as? AuthViewController
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
		switchToTabBarController()
	}
}
