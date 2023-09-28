//
//  ImagesListTests.swift
//  ImageFeedTests
//
//  Created by Andrey Ulanov on 27.09.2023.
//

import XCTest
@testable import ImageFeed

final class ImagesListTests: XCTestCase {
	func testIfViewControllerCallsViewDidLoad() {
		// Given
		let viewController = ImagesListViewController()
		let presenter = ImagesListPresenterSpy()
		viewController.presenter = presenter
		presenter.view = viewController
		
		// When
		_ = viewController.view
		
		// Then
		XCTAssertTrue(presenter.viewDidLoadCalled)
	}
}

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
	var viewDidLoadCalled = false
	var view: ImageFeed.ImagesListViewControllerProtocol?
	
	func viewDidLoad() {
		viewDidLoadCalled = true
	}
	
	func getImagesIfNeeded() {
		
	}
	
	func like(photo: ImageFeed.Photo, completion: (() -> Void)?) {
		
	}
}
