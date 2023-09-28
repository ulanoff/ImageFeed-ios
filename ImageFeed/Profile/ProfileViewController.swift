//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Andrey Ulanov on 13.07.2023.
//

import UIKit
import Kingfisher

protocol ProfileViewControllerProtocol: AnyObject {
	var presenter: ProfilePresenterProtocol? { get set }
	func showLogoutAlert()
	func setProfileDetails(profile: Profile)
	func setAvatarImage(url: URL)
	func switchToSplashViewController()
}

final class ProfileViewController: UIViewController, ProfileViewControllerProtocol {
	var presenter: ProfilePresenterProtocol?
	private var nameLabel: UILabel!
	private var idLabel: UILabel!
	private var descriptionLabel: UILabel!
	private var profilePicture: ProfilePicture!
	private var logoutButton: UIButton!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		setupUI()
		presenter?.viewDidLoad()
    }
	
	override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
	
	@objc private func didTapLogoutButton(_ button: UIButton) {
		presenter?.didTapLogoutButton()
	}
	
	func setAvatarImage(url: URL) {
		profilePicture.kf.setImage(with: url,
								   placeholder: UIImage(named: "avatar_placeholder"))
	}
	
	func setProfileDetails(profile: Profile) {
		nameLabel.text = profile.name
		idLabel.text = profile.loginName
		descriptionLabel.text = profile.bio
	}
	
	func showLogoutAlert() {
		let alert = UIAlertController(title: "Пока, пока!",
									  message: "Уверены что хотите выйти?",
									  preferredStyle: .alert)
		let agreeAction = UIAlertAction(title: "Да", style: .default) { [weak self] _ in
			guard let self else { return }
			presenter?.didConfirmLogout()
		}
		let disagreeAction = UIAlertAction(title: "Нет", style: .cancel) { [weak self] _ in
			guard let self else { return }
			dismiss(animated: true)
		}
		alert.addAction(disagreeAction)
		alert.addAction(agreeAction)
		present(alert, animated: true)
	}
	
	func switchToSplashViewController() {
		guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
		let splashViewController = SplashViewController()
		window.rootViewController = splashViewController
	}
}
private extension ProfileViewController {
	func setupUI() {
		configureNameLabel()
		configureIdLabel()
		configureDescriptionLabel()
		configureProfilePicture()
		configureLogoutButton()
		configureMainView()
		configureConstraints()
	}
	
	func configureMainView() {
		view.backgroundColor = .ypBlack
		[nameLabel, idLabel, descriptionLabel, profilePicture, logoutButton].forEach {
			view.addSubview($0)
		}
	}
	
	func configureNameLabel() {
		nameLabel = UILabel()
		nameLabel.font = .systemFont(ofSize: 23, weight: .bold)
		nameLabel.textColor = .ypWhite
		nameLabel.text = "Екатерина Новикова"
		nameLabel.numberOfLines = 1
	}
	
	func configureIdLabel() {
		idLabel = UILabel()
		idLabel.font = .systemFont(ofSize: 13)
		idLabel.textColor = .ypGray
		idLabel.text = "@ekaterina_nov"
		idLabel.numberOfLines = 1
	}
	
	func configureDescriptionLabel() {
		descriptionLabel = UILabel()
		descriptionLabel.font = .systemFont(ofSize: 13)
		descriptionLabel.textColor = .ypWhite
		descriptionLabel.text = "Hello, world!"
		descriptionLabel.numberOfLines = 0
	}
	
	func configureProfilePicture() {
		let image = UIImage(named: "avatar_placeholder") ?? UIImage()
		profilePicture = ProfilePicture(image: image)
	}
	
	func configureLogoutButton() {
		logoutButton = UIButton()
		let icon = UIImage(named: "Exit") ?? UIImage()
		logoutButton.setImage(icon, for: .normal)
		logoutButton.tintColor = .ypRed
		logoutButton.addTarget(self, action: #selector(didTapLogoutButton(_:)), for: .touchUpInside)
		logoutButton.accessibilityIdentifier = "logout button"
	}
	
	func configureConstraints() {
		let safeArea = view.safeAreaLayoutGuide
		[nameLabel, idLabel, descriptionLabel, profilePicture, logoutButton].forEach {
			$0.translatesAutoresizingMaskIntoConstraints = false
		}
		NSLayoutConstraint.activate([
			profilePicture.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 32),
			profilePicture.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
			profilePicture.widthAnchor.constraint(equalToConstant: 70),
			profilePicture.heightAnchor.constraint(equalToConstant: 70),
			
			logoutButton.centerYAnchor.constraint(equalTo: profilePicture.centerYAnchor),
			logoutButton.widthAnchor.constraint(equalToConstant: 44),
			logoutButton.heightAnchor.constraint(equalToConstant: 44),
			logoutButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16),
			
			nameLabel.topAnchor.constraint(equalTo: profilePicture.bottomAnchor, constant: 8),
			nameLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
			nameLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16),
			
			idLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
			idLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
			idLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16),
			
			descriptionLabel.topAnchor.constraint(equalTo: idLabel.bottomAnchor, constant: 8),
			descriptionLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
			descriptionLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16),
		])
	}
}
