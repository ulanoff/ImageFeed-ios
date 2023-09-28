//
//  WebViewTests.swift
//  WebViewTests
//
//  Created by Andrey Ulanov on 26.09.2023.
//

import XCTest
@testable import ImageFeed

final class WebViewTests: XCTestCase {
	func testIfViewControllerCallsViewDidLoad() {
		// Given
		let viewController = WebViewViewController()
		let presenter = WebViewPresenterSpy()
		viewController.presenter = presenter
		presenter.view = viewController
		
		// When
		_ = viewController.view
		
		// Then
		XCTAssertTrue(presenter.viewDidLoadCalled)
	}
	
	func testIfPresenterCallsLoadRequest() {
		// Given
		let viewController = WebViewViewControllerSpy()
		let presenter = WebViewPresenter(authHelper: AuthHelper())
		viewController.presenter = presenter
		presenter.view = viewController
		
		// When
		presenter.viewDidLoad()
		
		// Then
		XCTAssertTrue(viewController.loadRequestCalled)
	}
	
	func testIfProgressVisibleWhenLessThenOne() {
		// Given
		let presenter = WebViewPresenter(authHelper: AuthHelper())
		let progress: Float = 0.6
		
		// When
		let shouldHideProgress = presenter.shouldHideProgressBar(for: progress)
		
		// Then
		XCTAssertFalse(shouldHideProgress)
	}
	
	func testIfProgressHiddenWhenOne() {
		// Given
		let presenter = WebViewPresenter(authHelper: AuthHelper())
		let progress: Float = 1
		
		// When
		let shouldHideProgress = presenter.shouldHideProgressBar(for: progress)
		
		// Then
		XCTAssertTrue(shouldHideProgress)
	}
	
	func testAuthHelperAuthURL() {
		// Given
		let configuration = AuthConfiguration.standart
		let authHelper = AuthHelper(configuration: configuration)
		
		// When
		let url = authHelper.authURL()
		let urlString = url.absoluteString
		
		// Then
		XCTAssertTrue(urlString.contains(configuration.authURLString))
		XCTAssertTrue(urlString.contains(configuration.accessKey))
		XCTAssertTrue(urlString.contains(configuration.redirectURI))
		XCTAssertTrue(urlString.contains(configuration.responseType))
		XCTAssertTrue(urlString.contains(configuration.accessScope))
	}
	
	func testCodeFromURL() {
		// Given
		let authHelper = AuthHelper()
		var testURLComponents = URLComponents(string: "https://unsplash.com/oauth/authorize/native")
		testURLComponents?.queryItems = [
			URLQueryItem(name: "code", value: "test code")
		]
		let url = testURLComponents?.url
		
		// When
		let code = authHelper.code(from: url!)
		
		// Then
		XCTAssertEqual(code, "test code")
	}
}

final class WebViewViewControllerSpy: WebViewViewControllerProtocol {
	var loadRequestCalled = false
	var presenter: ImageFeed.WebViewPresenterProtocol?
	
	func load(request: URLRequest) {
		loadRequestCalled = true
	}
	
	func setProgressValue(_ newValue: Float) {
		
	}
	
	func setProgressHidden(_ isHiddent: Bool) {
		
	}
}

final class WebViewPresenterSpy: WebViewPresenterProtocol {
	var viewDidLoadCalled = false
	var view: ImageFeed.WebViewViewControllerProtocol?
	
	func viewDidLoad() {
		viewDidLoadCalled = true
	}
	
	func didUpdateProgressValue(_ newValue: Double) {
		
	}
	
	func code(from url: URL) -> String? {
		return nil
	}
}
