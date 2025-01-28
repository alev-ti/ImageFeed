import XCTest

final class ImageFeedUITest: XCTestCase {
    
//    Fill data for testing
    let email = ""
    let password = ""
    let fullname = ""
    let username = ""
    
    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["testMode"]
        app.launch()
        
    }
    
    func testAuth() throws {
        app.buttons["Authenticate"].tap()
        
        let webView = app.webViews["UnsplashWebView"]
        
        XCTAssertTrue(webView.waitForExistence(timeout: 5))
        
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        
        loginTextField.tap()
        sleep(3)
        loginTextField.typeText(email)
        sleep(3)
        webView.tap()
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        
        passwordTextField.tap()
        sleep(3)
        passwordTextField.typeText(password)
        sleep(3)
        webView.swipeUp()
        sleep(3)
        
        webView.buttons["Login"].tap()
        
        let tablesQuery = app.tables
        let cell = tablesQuery.descendants(matching: .cell).element(boundBy: 0)
        
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }
    
    func testFeed() throws {
        let tablesQuery = app.tables["ImagesListTableView"]
        
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        cell.swipeUp()
        
        sleep(3)
        
        let cellToLike = tablesQuery.descendants(matching: .cell).element(boundBy: 1)
        let likeButton = cellToLike.descendants(matching: .button).element(boundBy: 0)
        
        likeButton.tap()
        sleep(2)
        
        likeButton.tap()
        sleep(2)
        
        cellToLike.tap()
        sleep(3)
        
        let image = app.scrollViews.images.element(boundBy: 0)
        image.pinch(withScale: 3, velocity: 1)
        image.pinch(withScale: 0.5, velocity: -1)
        
        let navBackButtonWhiteButton = app.buttons["nav_back_btn"]
        navBackButtonWhiteButton.tap()
    }
    
    func testProfile() throws {
        sleep(3)
        app.tabBars.buttons.element(boundBy: 1).tap()
        
        let fullnameLabel = app.staticTexts[fullname]
        XCTAssertTrue(fullnameLabel.waitForExistence(timeout: 5))
        
        let usernameLabel = app.staticTexts[username]
        XCTAssertTrue(usernameLabel.waitForExistence(timeout: 5))
        
        app.buttons["logout_btn"].tap()
        app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Да"].tap()
        
        sleep(3)
        XCTAssertTrue(app.buttons["Authenticate"].exists)
    }
    
}
