import Candle
import XCTest

@MainActor
class MyTest: XCTestCase {

    private func testLogin(
        application: XCUIApplication, username: String, mfa: (placeholder: String, value: String)?,
        userID: String
    ) async {
        // Tap to login
        let loginMenu = application.staticTexts["Login"]
        XCTAssert(loginMenu.exists)
        loginMenu.tap()

        // Select demo provider
        let demoButton = application.buttons["Demo"]
        XCTAssert(demoButton.exists)
        demoButton.tap()

        // Enter username
        let usernameTextField = application.textFields["Username"]
        XCTAssert(usernameTextField.exists)
        usernameTextField.tap()
        usernameTextField.tap()  // NOTE: This is necessary for some reason
        usernameTextField.typeText(username)

        // Tap to submit
        let submitButton = application.buttons["Submit"]
        XCTAssert(submitButton.exists)
        submitButton.tap()

        if let mfa = mfa {
            // Wait for MFA request
            XCTAssert(application.staticTexts["MFA Response"].waitForExistence(timeout: 30))

            // Enter MFA response
            let mfaResponseTextField = application.textFields[mfa.placeholder]
            XCTAssert(mfaResponseTextField.exists)
            mfaResponseTextField.tap()
            mfaResponseTextField.tap()  // NOTE: This is necessary for some reason
            mfaResponseTextField.typeText(mfa.value)

            // Tap to submit
            let submitButton = application.buttons["Submit"]
            XCTAssert(submitButton.exists)
            submitButton.tap()
        }

        // Wait for account linking
        XCTAssert(application.staticTexts["Linked Account"].waitForExistence(timeout: 30))

        // Verify user ID
        XCTAssert(application.staticTexts[userID].exists)

        // Tap to dismiss
        let doneButton = application.buttons["Done"]
        XCTAssert(doneButton.exists)
        doneButton.tap()
    }

    private func testIntegration() async {
        // Launch app
        let application = XCUIApplication()
        application.launch()

        // Tap to open session
        let openSessionButton = application.buttons["Open Session"]
        XCTAssert(openSessionButton.exists)
        openSessionButton.tap()

        // Wait for session to be opened
        XCTAssert(application.staticTexts["Candle Session"].waitForExistence(timeout: 30))

        await testLogin(
            application: application,
            username: "Antonette",
            mfa: nil,
            userID: "user_2")
        await testLogin(
            application: application,
            username: "Kamren",
            mfa: (placeholder: "Login Code (from app)", value: "625342"),
            userID: "user_5")
        await testLogin(
            application: application,
            username: "Delphine",
            mfa: (placeholder: "Magic Link (copy from sms/email)", value: "conrad.com"),
            userID: "user_9")
    }

    func testLaunch() async {
        // Launch app
        let application = XCUIApplication()
        application.launch()

        // Check that the app has launched

        XCTAssert(application.staticTexts["Candle"].waitForExistence(timeout: 5))
        XCTAssert(application.buttons["Get Started"].exists)
    }
}
