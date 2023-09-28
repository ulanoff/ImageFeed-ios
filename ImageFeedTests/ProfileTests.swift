//
//  ProfileTests.swift
//  ImageFeedTests
//
//  Created by Andrey Ulanov on 27.09.2023.
//

import XCTest
@testable import ImageFeed

final class ProfileTests: XCTestCase {
	func testIfViewControllerCallsViewDidLoad() {
		// Given
		let viewController = ProfileViewController()
		let presenter = ProfilePresenterSpy()
		viewController.presenter = presenter
		presenter.view = viewController
		
		// When
		_ = viewController.view
		
		// Then
		XCTAssertTrue(presenter.viewDidLoadCalled)
	}
	
	func testIfViewControllerCallSwitchToSplashViewControllerOnLogoutConfirm() {
		// Given
		let viewController = ProfileViewControllerSpy()
		let presenter = ProfilePresenter()
		viewController.presenter = presenter
		presenter.view = viewController
		
		// When
		presenter.didConfirmLogout()
		
		// Then
		XCTAssertTrue(viewController.switchToSplashViewControllerCalled)
	}
	
	func testIfPresenterCallShowLogoutAlert() {
		// Given
		let viewController = ProfileViewControllerSpy()
		let presenter = ProfilePresenter()
		viewController.presenter = presenter
		presenter.view = viewController
		
		// When
		presenter.didTapLogoutButton()
		
		// Then
		XCTAssertTrue(viewController.showLogoutAlertCalled)
	}
}

final class ProfilePresenterSpy: ProfilePresenterProtocol {
	var viewDidLoadCalled = false
	
	var view: ImageFeed.ProfileViewControllerProtocol?
	
	func viewDidLoad() {
		viewDidLoadCalled = true
	}
	
	func didTapLogoutButton() {
		
	}
	
	func didConfirmLogout() {
		
	}
}

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
	var switchToSplashViewControllerCalled = false
	var showLogoutAlertCalled = false
	var presenter: ImageFeed.ProfilePresenterProtocol?
	
	func showLogoutAlert() {
		showLogoutAlertCalled = true
	}
	
	func setProfileDetails(profile: ImageFeed.Profile) {
		
	}
	
	func setAvatarImage(url: URL) {
		
	}
	
	func switchToSplashViewController() {
		switchToSplashViewControllerCalled = true
	}
}
