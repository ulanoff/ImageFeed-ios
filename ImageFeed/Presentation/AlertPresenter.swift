//
//  AlertPresenter.swift
//  ImageFeed
//
//  Created by Andrey Ulanov on 19.08.2023.
//

import UIKit

struct AlertModel {
	let title: String
	let message: String
	let buttonText: String
	let completion: (() -> Void)?
}

final class AlertPresenter {
	static let shared = AlertPresenter()
	
	func presentAlert(in controller: UIViewController, with result: AlertModel) {
		let alert = UIAlertController(title: result.title,
									  message: result.message,
									  preferredStyle: .alert)
		alert.view.accessibilityIdentifier = "Alert"
		let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
			if let completion = result.completion {
				completion()
				return
			}
		}
		alert.addAction(action)
		controller.present(alert, animated: true)
	}
}
