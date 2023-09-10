//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by Andrey Ulanov on 11.08.2023.
//

import UIKit
import WebKit

protocol WebViewViewControllerDelegate: AnyObject {
	func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
	func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

final class WebViewViewController: UIViewController {
	weak var delegate: WebViewViewControllerDelegate?
	
	@IBOutlet private var webView: WKWebView!
	@IBOutlet private var progressBar: UIProgressView!

    override func viewDidLoad() {
        super.viewDidLoad()
		
		webView.navigationDelegate = self
		
		var urlComponents = URLComponents(url: UnsplashApiConstants.UnsplashAuthorizeURL, resolvingAgainstBaseURL: true)!
		urlComponents.queryItems = [
			URLQueryItem(name: "client_id", value: UnsplashApiConstants.AccessKey),
			URLQueryItem(name: "redirect_uri", value: UnsplashApiConstants.RedirectURI),
			URLQueryItem(name: "response_type", value: UnsplashApiConstants.ResponseType),
			URLQueryItem(name: "scope", value: UnsplashApiConstants.AccessScope),
		]
		let url = urlComponents.url!
		
		let request = URLRequest(url: url)
		webView.load(request)
		
		updateProgress()
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		webView.addObserver(self,
							forKeyPath: #keyPath(WKWebView.estimatedProgress),
							options: [.new],
							context: nil)
		updateProgress()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		webView.removeObserver(self,
							   forKeyPath: #keyPath(WKWebView.estimatedProgress),
							   context: nil)
	}
	
	override func observeValue(
		forKeyPath keyPath: String?,
		of object: Any?,
		change: [NSKeyValueChangeKey : Any]?,
		context: UnsafeMutableRawPointer?
	) {
		if keyPath == #keyPath(WKWebView.estimatedProgress) {
			updateProgress()
		} else {
			super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
		}
	}
	
	@IBAction private func didTapBackButton(_ sender: Any?) {
		delegate?.webViewViewControllerDidCancel(self)
	}
	
	private func updateProgress() {
		progressBar.progress = Float(webView.estimatedProgress)
		progressBar.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
	}
	
	private func code(from navigationAction: WKNavigationAction) -> String? {
		if
			let url = navigationAction.request.url,
			let urlComponents = URLComponents(string: url.absoluteString),
			urlComponents.path == "/oauth/authorize/native",
			let items = urlComponents.queryItems,
			let codeItem = items.first(where: { $0.name == UnsplashApiConstants.ResponseType })
		{
			return codeItem.value
		} else {
			return nil
		}
	}
}

extension WebViewViewController: WKNavigationDelegate {
	func webView(_ webView: WKWebView,
				 decidePolicyFor navigationAction: WKNavigationAction,
				 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
	) {
		if let code = code(from: navigationAction) {
			delegate?.webViewViewController(self, didAuthenticateWithCode: code)
			decisionHandler(.cancel)
		} else {
			decisionHandler(.allow)
		}
	}
}
