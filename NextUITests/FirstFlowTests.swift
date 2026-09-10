import XCTest

@MainActor
final class FirstFlowTests: XCTestCase {
    func testLongTextAtLargestDynamicType() throws {
        let app = launchIsolated(largeText: true)
        createVision(app, title: "Become a software engineer in Australia, creating thoughtful products that help people move toward what matters to them.")
        let input = statementInput(app)
        XCTAssertTrue(input.waitForExistence(timeout: 8))
        input.tap()
        input.typeText("Read one developer position description and write a short application describing a relevant example from my portfolio.")
        XCTAssertTrue(app.buttons["saveStep"].isHittable)
        app.buttons["saveStep"].tap()
        XCTAssertTrue(app.buttons["activeStep"].waitForExistence(timeout: 8))
        capture(app, name: "Home — largest Dynamic Type")
        for _ in 0..<8 where !app.buttons["visionSummary"].isHittable { app.swipeUp() }
        XCTAssertTrue(app.buttons["visionSummary"].isHittable)
        app.buttons["visionSummary"].tap()
        XCTAssertTrue(app.buttons["saveVision"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.buttons["saveVision"].isHittable)
        capture(app, name: "Vision editor — keyboard and largest Dynamic Type")
        app.buttons["Cancel"].tap()
    }

    func testOnboardingAndStepSurviveRelaunch() throws {
        let app = launchIsolated()
        createVision(app, title: "Become a software engineer in Australia.")
        let input = statementInput(app)
        XCTAssertTrue(input.waitForExistence(timeout: 8))
        XCTAssertFalse(app.buttons["saveStep"].isEnabled)
        input.tap()
        input.typeText("Apply for one developer position.")
        capture(app, name: "First Step — keyboard")
        app.buttons["saveStep"].tap()
        XCTAssertTrue(app.buttons["activeStep"].waitForExistence(timeout: 8))
        capture(app, name: "Home — default type")
        try app.performAccessibilityAudit(for: [.contrast, .hitRegion, .sufficientElementDescription])
        app.terminate()
        app.launch()
        XCTAssertTrue(app.buttons["activeStep"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.buttons["activeStep"].label.contains("Apply for one developer position."))
        XCTAssertTrue(app.buttons["visionSummary"].label.contains("Become a software engineer in Australia."))
        XCTAssertFalse(app.buttons["getStarted"].exists)
    }

    func testInterruptedSetupResumesWithSavedVision() throws {
        let app = launchIsolated()
        createVision(app, title: "Write a book.")
        XCTAssertTrue(app.buttons["saveStep"].waitForExistence(timeout: 8))
        app.terminate()
        app.launch()
        XCTAssertTrue(app.buttons["addNextStep"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.buttons["visionSummary"].label.contains("Write a book."))
        app.buttons["addNextStep"].tap()
        let input = statementInput(app)
        XCTAssertTrue(input.waitForExistence(timeout: 8))
        input.tap()
        input.typeText("Write the first paragraph.")
        app.buttons["saveStep"].tap()
        XCTAssertTrue(app.buttons["activeStep"].waitForExistence(timeout: 8))
    }

    func testEditCancelAndSavePreserveTheSingleStep() throws {
        let app = launchIsolated()
        createVision(app, title: "Learn Korean.")
        var input = statementInput(app)
        XCTAssertTrue(input.waitForExistence(timeout: 8))
        input.tap()
        input.typeText("Read a page.")
        app.buttons["saveStep"].tap()
        XCTAssertTrue(app.buttons["activeStep"].waitForExistence(timeout: 8))
        app.buttons["activeStep"].tap()
        XCTAssertTrue(app.buttons["editStep"].waitForExistence(timeout: 8))
        app.buttons["editStep"].tap()
        input = statementInput(app)
        XCTAssertTrue(input.waitForExistence(timeout: 8))
        input.tap()
        input.typeText(" Unsaved text")
        app.buttons["Cancel"].tap()
        app.buttons["Close"].tap()
        XCTAssertTrue(app.buttons["activeStep"].waitForExistence(timeout: 8))
        XCTAssertFalse(app.buttons["activeStep"].label.contains("Unsaved"))
        app.buttons["activeStep"].tap()
        XCTAssertTrue(app.buttons["editStep"].waitForExistence(timeout: 8))
        app.buttons["editStep"].tap()
        input = statementInput(app)
        XCTAssertTrue(input.waitForExistence(timeout: 8))
        input.tap()
        input.typeText(" Learn one word.")
        app.buttons["saveStep"].tap()
        XCTAssertTrue(app.buttons["activeStep"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.buttons["activeStep"].label.contains("Learn one word."))
        app.terminate()
        app.launch()
        XCTAssertTrue(app.buttons["activeStep"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.buttons["activeStep"].label.contains("Learn one word."))
        XCTAssertFalse(app.buttons["addNextStep"].exists)
    }

    private func launchIsolated(largeText: Bool = false) -> XCUIApplication {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments = ["--ui-test-store", UUID().uuidString, "-AppleLanguages", "(en)", "-AppleLocale", "en_AU"]
        if largeText {
            app.launchArguments += ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL", "--ui-test-dark"]
        }
        app.launch()
        return app
    }

    private func createVision(_ app: XCUIApplication, title: String) {
        XCTAssertTrue(app.buttons["getStarted"].waitForExistence(timeout: 10))
        app.buttons["getStarted"].tap()
        let input = statementInput(app)
        XCTAssertTrue(input.waitForExistence(timeout: 8))
        XCTAssertFalse(app.buttons["continueVision"].isEnabled)
        input.tap()
        input.typeText(title)
        app.buttons["continueVision"].tap()
    }

    private func statementInput(_ app: XCUIApplication) -> XCUIElement {
        app.descendants(matching: .any).matching(identifier: "statementInput").firstMatch
    }

    private func capture(_ app: XCUIApplication, name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
