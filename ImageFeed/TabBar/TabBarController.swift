//
//  TabBarController.swift
//  ImageFeed
//
//  Created by Andrey Ulanov on 14.09.2023.
//

import UIKit

final class TabBarController: UITabBarController {
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		tabBar.barTintColor = .ypBlack
		tabBar.backgroundColor = .ypBlack
		tabBar.tintColor = .ypWhite
		
		
		let imagesListViewController = ImagesListViewController()
		let imagesListPresenter = ImagesListPresenter()
		imagesListViewController.presenter = imagesListPresenter
		imagesListPresenter.view = imagesListViewController
		imagesListViewController.tabBarItem = UITabBarItem(
			title: "",
			image: UIImage(named: "tab_editorial_active"),
			selectedImage: nil
		)
		
		let profileViewController = ProfileViewController()
		let profilePresenter = ProfilePresenter()
		profileViewController.presenter = profilePresenter
		profilePresenter.view = profileViewController
		profileViewController.tabBarItem = UITabBarItem(
			title: "",
			image: UIImage(named: "tab_profile_active"),
			selectedImage: nil
		)
		
		viewControllers = [imagesListViewController, profileViewController]
	}
}
