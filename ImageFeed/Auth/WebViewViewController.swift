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
	private var estimatedProgressObservation: NSKeyValueObservation?
	
	private var webView: WKWebView!
	private var progressBar: UIProgressView!
	private var backButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
		setupUI()
		
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
		
		estimatedProgressObservation = webView.observe(\.estimatedProgress) { [weak self] _, _ in
			guard let self else { return }
			updateProgress()
		}
	
		updateProgress()
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
	
	@objc private func didTapBackButton(_ sender: UIButton?) {
		delegate?.webViewViewControllerDidCancel(self)
	}
}

private extension WebViewViewController {
	func setupUI() {
		configureWebView()
		configureBackButton()
		configureProgressBar()
		configureMainView()
		configureConstraints()
	}
	
	func configureMainView() {
		view.backgroundColor = .ypWhite
		[webView, progressBar, backButton].forEach {
			view.addSubview($0)
		}
	}
	
	func configureWebView() {
		webView = WKWebView()
		webView.backgroundColor = .ypWhite
	}
	
	func configureBackButton() {
		backButton = UIButton()
		let icon = UIImage(named: "Backward") ?? UIImage()
		backButton.setImage(icon, for: .normal)
		backButton.tintColor = .ypBlack
		backButton.addTarget(self, action: #selector(didTapBackButton(_:)), for: .touchUpInside)
	}
	
	func configureProgressBar() {
		progressBar = UIProgressView()
		progressBar.progressTintColor = .ypBlack
		progressBar.trackTintColor = .ypGray
		progressBar.progress = 0.5
		progressBar.progressViewStyle = .bar
	}
	
	func configureConstraints() {
		let safeArea = view.safeAreaLayoutGuide
		[webView, progressBar, backButton].forEach {
			$0.translatesAutoresizingMaskIntoConstraints = false
		}
		NSLayoutConstraint.activate([
			webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			webView.topAnchor.constraint(equalTo: progressBar.bottomAnchor),
			
			backButton.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 9),
			backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 9),
			backButton.widthAnchor.constraint(equalToConstant: 24),
			backButton.heightAnchor.constraint(equalToConstant: 24),
			
			progressBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			progressBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			progressBar.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 8),
		])
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

