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
		imagesListViewController.tabBarItem = UITabBarItem(
			title: "",
			image: UIImage(named: "tab_editorial_active"),
			selectedImage: nil
		)
		
		let profileViewController = ProfileViewController()
		profileViewController.tabBarItem = UITabBarItem(
			title: "",
			image: UIImage(named: "tab_profile_active"),
			selectedImage: nil
		)
		
		viewControllers = [imagesListViewController, profileViewController]
	}
}
