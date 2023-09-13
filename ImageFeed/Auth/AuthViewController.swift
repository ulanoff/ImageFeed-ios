//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Andrey Ulanov on 11.08.2023.
//

import UIKit
import ProgressHUD

protocol AuthViewControllerDelegate: AnyObject {
	func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String)
}

final class AuthViewController: UIViewController {
	weak var delegate: AuthViewControllerDelegate?
	private let showWebViewSegueIdentifier = "ShowWebView"
	private let oauth2Service = OAuth2Service()
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == showWebViewSegueIdentifier {
			guard let webViewVC = segue.destination as? WebViewViewController else {
				assertionFailure("Failed to prepare for \(showWebViewSegueIdentifier)")
				return
			}
			webViewVC.delegate = self
		} else {
			super.prepare(for: segue, sender: sender)
		}
	}
}

extension AuthViewController: WebViewViewControllerDelegate {
	func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
		UIBlockingProgressHUD.show()
		oauth2Service.fetchAuthToken(code: code) { [weak self] result in
			guard let self else { return }
			switch result {
			case .success(let token):
				OAuth2TokenStorage.shared.token = token
				self.delegate?.authViewController(self, didAuthenticateWithCode: token)
				UIBlockingProgressHUD.dismiss()
			case .failure(let error):
				let alertModel = AlertModel(title: "Что-то пошло не так(",
											message: "Не удалось войти в систему",
											buttonText: "Ок",
											completion: nil)
				AlertPresenter.shared.presentAlert(in: self, with: alertModel)
				assertionFailure(error.localizedDescription)
				UIBlockingProgressHUD.dismiss()
			}
		}
	}
	
	func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
		vc.dismiss(animated: true)
	}
}
