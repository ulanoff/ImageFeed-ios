//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Andrey Ulanov on 11.08.2023.
//

import UIKit

protocol AuthViewControllerDelegate: AnyObject {
	func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String)
}

final class AuthViewController: UIViewController {
	private let ShowWebViewSegueIdentifier = "ShowWebView"
	private let oauth2Service = OAuth2Service()
	private let oauth2TokenStorage = OAuth2TokenStorage()
	weak var delegate: AuthViewControllerDelegate?
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == ShowWebViewSegueIdentifier {
			guard let webViewVC = segue.destination as? WebViewViewController else {
				fatalError("Failed to prepare for \(ShowWebViewSegueIdentifier)")
			}
			webViewVC.delegate = self
		} else {
			super.prepare(for: segue, sender: sender)
		}
	}
}

extension AuthViewController: WebViewViewControllerDelegate {
	func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
		oauth2Service.fetchAuthToken(code: code) { [weak self] result in
			guard let self else { return }
			switch result {
			case .success(let data):
				let decoder = JSONDecoder()
				decoder.keyDecodingStrategy = .convertFromSnakeCase
				do {
					let oAuthTokenResponseBody = try decoder.decode(OAuthTokenResponseBody.self, from: data)
					oauth2TokenStorage.token = oAuthTokenResponseBody.accessToken
					self.delegate?.authViewController(self, didAuthenticateWithCode: code)
				} catch {
					assertionFailure("Failed to decode data as OAuthTokenResponseBody type")
				}
			case .failure(let error):
				assertionFailure(error.localizedDescription)
			}
		}
	}
	
	func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
		vc.dismiss(animated: true)
	}
}
