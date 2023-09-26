//
//  WebViewPresenter.swift
//  ImageFeed
//
//  Created by Andrey Ulanov on 26.09.2023.
//

import Foundation

protocol WebViewPresenterProtocol: AnyObject {
	var view: WebViewViewControllerProtocol? { get set }
	func viewDidLoad()
	func didUpdateProgressValue(_ newValue: Double)
	func code(from url: URL) -> String?
}

final class WebViewPresenter: WebViewPresenterProtocol {
	weak var view: WebViewViewControllerProtocol?
	private let authConfiguration = AuthConfiguration.standart
	private let authHelper: AuthHelperProtocol
	
	init(authHelper: AuthHelperProtocol) {
		self.authHelper = authHelper
	}
	
	func viewDidLoad() {
		let request = authHelper.authRequest()
		view?.load(request: request)
		didUpdateProgressValue(0)
	}
	
	func didUpdateProgressValue(_ newValue: Double) {
		let newProgressValue = Float(newValue)
		view?.setProgressValue(newProgressValue)
		
		let shouldHideProgressBar = shouldHideProgressBar(for: newProgressValue)
		view?.setProgressHidden(shouldHideProgressBar)
	}
	
	func code(from url: URL) -> String? {
		authHelper.code(from: url)
	}
	
	private func shouldHideProgressBar(for value: Float) -> Bool {
		return abs(value - 1.0) <= 0.001
	}
}
