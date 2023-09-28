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

protocol WebViewViewControllerProtocol: AnyObject {
	var presenter: WebViewPresenterProtocol? { get set }
	func load(request: URLRequest)
	func setProgressValue(_ newValue: Float)
	func setProgressHidden(_ isHiddent: Bool)
}

final class WebViewViewController: UIViewController, WebViewViewControllerProtocol {
	weak var delegate: WebViewViewControllerDelegate?
	var presenter: WebViewPresenterProtocol?
	private var estimatedProgressObservation: NSKeyValueObservation?
	
	private var webView: WKWebView!
	private var progressBar: UIProgressView!
	private var backButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
		setupUI()
		webView.navigationDelegate = self
		presenter?.viewDidLoad()
		
		estimatedProgressObservation = webView.observe(\.estimatedProgress) { [weak self] _, _ in
			guard let self else { return }
			presenter?.didUpdateProgressValue(webView.estimatedProgress)
		}
    }
	
	func load(request: URLRequest) {
		webView.load(request)
	}
	
	func setProgressValue(_ newValue: Float) {
		progressBar.progress = newValue
	}
	
	func setProgressHidden(_ isHiddent: Bool) {
		progressBar.isHidden = isHiddent
	}
	
	private func updateProgress() {
		progressBar.progress = Float(webView.estimatedProgress)
		progressBar.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
	}
	
	private func code(from navigationAction: WKNavigationAction) -> String? {
		guard let url = navigationAction.request.url
		else { return nil }
		let code = presenter?.code(from: url)
		return code
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
		webView.accessibilityIdentifier = "auth web view"
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

