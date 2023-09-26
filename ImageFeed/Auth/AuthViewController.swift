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
	weak var delegate: AuthViewControllerDelegate?
	private let oauth2Service = OAuth2Service()
	
	private var unsplashLogoImageView: UIImageView!
	private var loginButton: UIButton!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
	}
	
	@objc private func didTapLoginButton(_ sender: UIButton?) {
		let webViewVC = WebViewViewController()
		let authHelper = AuthHelper()
		let webViewPresenter = WebViewPresenter(authHelper: authHelper)
		
		webViewVC.delegate = self
		webViewVC.presenter = webViewPresenter
		webViewVC.modalPresentationStyle = .fullScreen
		
		webViewPresenter.view = webViewVC
		
		present(webViewVC, animated: true)
	}
}

private extension AuthViewController {
	func setupUI() {
		configureLogoImageView()
		configureLoginButton()
		configureMainView()
		configureConstraints()
	}
	
	func configureMainView() {
		view.backgroundColor = .ypBlack
		[unsplashLogoImageView, loginButton].forEach {
			view.addSubview($0)
		}
	}
	
	func configureLogoImageView() {
		unsplashLogoImageView = UIImageView()
		unsplashLogoImageView.image = UIImage(named: "unsplash_logo")
		unsplashLogoImageView.tintColor = .white
	}
	
	func configureLoginButton() {
		loginButton = UIButton()
		loginButton.setTitle("Войти", for: .normal)
		loginButton.setTitleColor(.ypBlack, for: .normal)
		loginButton.titleLabel?.font = .boldSystemFont(ofSize: 17)
		loginButton.backgroundColor = .ypWhite
		loginButton.layer.cornerRadius = 16
		loginButton.addTarget(self, action: #selector(didTapLoginButton(_:)), for: .touchUpInside)
	}
	
	func configureConstraints() {
		let safeArea = view.safeAreaLayoutGuide
		[unsplashLogoImageView, loginButton].forEach {
			$0?.translatesAutoresizingMaskIntoConstraints = false
		}
		NSLayoutConstraint.activate([
			unsplashLogoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
			unsplashLogoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			unsplashLogoImageView.widthAnchor.constraint(equalToConstant: 60),
			unsplashLogoImageView.heightAnchor.constraint(equalToConstant: 60),
			
			loginButton.heightAnchor.constraint(equalToConstant: 48),
			loginButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
			loginButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16),
			loginButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -90),
		])
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
