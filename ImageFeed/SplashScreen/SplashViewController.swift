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
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		if let _ = OAuth2TokenStorage.shared.token {
			performSegue(withIdentifier: showGalleryScreenSegueIdentifier, sender: nil)
		} else {
			performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
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
		switchToTabBarController()
	}
}
