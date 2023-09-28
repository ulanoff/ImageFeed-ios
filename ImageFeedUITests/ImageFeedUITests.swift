//
//  ImageFeedUITests.swift
//  ImageFeedUITests
//
//  Created by Andrey Ulanov on 28.09.2023.
//
import XCTest

class ImageFeedUITests: XCTestCase {
	private let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false

		app.launch()
    }
	
	func testAuth() throws {
		app.buttons["auth button"].tap()
		
		let webView = app.webViews["auth web view"]
		
		XCTAssertTrue(webView.waitForExistence(timeout: 5))

		let loginTextField = webView.descendants(matching: .textField).element
		XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
		
		loginTextField.tap()
		loginTextField.typeText("<Unsplash Account Email>")
		app.toolbars.buttons["Done"].tap()
		webView.swipeUp()
		
		let passwordTextField = webView.descendants(matching: .secureTextField).element
		XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
		
		passwordTextField.tap()
		passwordTextField.typeText("<Unsplash Account Password>")
		app.toolbars.buttons["Done"].tap()
		webView.swipeUp()
		
		webView.buttons["Login"].tap()
		
		let tablesQuery = app.tables
		let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
		XCTAssertTrue(cell.waitForExistence(timeout: 5))
	}


	func testFeed() throws {
        let tablesQuery = app.tables
        sleep(3)
        
        app.swipeUp()
        sleep(2)
        app.swipeDown()
        sleep(2)
        
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)
        let likeButton = cellToLike.buttons["like button"]
    
        likeButton.press(forDuration: 1, thenDragTo: likeButton)
        sleep(2)
        likeButton.press(forDuration: 1, thenDragTo: likeButton)
        sleep(2)

        cellToLike.tap()
        sleep(5)
		
		let image = app.scrollViews.images.element(boundBy: 0)
		image.pinch(withScale: 3, velocity: 1)
		image.pinch(withScale: 0.5, velocity: -1)
		
		let backButton = app.buttons["back button"]
		backButton.tap()
	}
    
func testProfile() throws {
		sleep(3)
    
		app.tabBars.buttons.element(boundBy: 1).tap()
		XCTAssertTrue(app.staticTexts["Andrey Ulanov"].exists)
		XCTAssertTrue(app.staticTexts["@theulanoff"].exists)
		app.buttons["logout button"].tap()
		app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Да"].tap()
	}
}
