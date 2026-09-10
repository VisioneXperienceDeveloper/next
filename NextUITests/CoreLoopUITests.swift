import XCTest

@MainActor
final class CoreLoopUITests: XCTestCase {
    func testReflectionJourneyAndScreenshots() throws {
        let app = launch()
        capture(app, "Store-01-Welcome")
        createVision(app)
        createStep(app, "Sketch the first page of my portfolio.")
        complete(app)
        app.buttons["skipReflection"].tap()
        createStep(app, "Build a simple portfolio page.")
        complete(app)
        app.buttons["addReflection"].tap()
        fill(app, "A small page helped me explain what I can build.")
        app.staticTexts["What did you learn?"].tap()
        let keyboardHidden = expectation(for: NSPredicate(format: "exists == false"), evaluatedWith: app.keyboards.firstMatch)
        wait(for: [keyboardHidden], timeout: 5)
        capture(app, "Store-04-Reflection")
        app.buttons["saveReflection"].tap()
        createStep(app, "Apply for one developer position.")
        capture(app, "Store-02-Home")
        app.buttons["activeStep"].tap()
        capture(app, "Store-03-Next-Step")
        app.buttons["Close"].tap()
        app.terminate()
        app.launch()
        XCTAssertTrue(app.buttons["activeStep"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["activeStep"].label.contains("Apply for one developer position."))
        app.buttons["viewJourney"].tap()
        XCTAssertTrue(app.staticTexts["Build a simple portfolio page."].waitForExistence(timeout: 8))
        XCTAssertTrue(app.staticTexts["A small page helped me explain what I can build."].exists)
        XCTAssertTrue(app.staticTexts["Sketch the first page of my portfolio."].exists)
        capture(app, "Store-05-Journey")
        try app.performAccessibilityAudit(for: [.contrast, .hitRegion, .sufficientElementDescription])
    }

    func testCompletionSkipInterruptionAndDelete() throws {
        let app = launch()
        createVision(app)
        createStep(app, "Read one role description.")
        complete(app)
        XCTAssertTrue(app.buttons["addReflection"].waitForExistence(timeout: 8))
        capture(app, "QA-Completed")
        app.terminate()
        app.launch()
        XCTAssertTrue(app.buttons["addNextStep"].waitForExistence(timeout: 10))
        app.buttons["addNextStep"].tap()
        createStep(app, "Write one application.")
        app.buttons["visionSummary"].tap()
        XCTAssertTrue(app.buttons["deleteVision"].waitForExistence(timeout: 8))
        app.buttons["deleteVision"].tap()
        XCTAssertTrue(app.buttons["Cancel"].waitForExistence(timeout: 8))
        app.buttons["Cancel"].tap()
        XCTAssertTrue(app.buttons["saveVision"].exists)
        app.buttons["deleteVision"].tap()
        let delete = app.buttons.matching(identifier: "Delete Vision").firstMatch
        XCTAssertTrue(delete.waitForExistence(timeout: 8))
        delete.tap()
        XCTAssertTrue(app.buttons["getStarted"].waitForExistence(timeout: 8))
        app.terminate()
        app.launch()
        XCTAssertTrue(app.buttons["getStarted"].waitForExistence(timeout: 8))
    }

    func testLargestTextCompletionReflectionAndJourney() throws {
        let app = launch(largeText: true)
        createVision(app)
        createStep(app, "Read a developer role description.")
        complete(app)
        capture(app, "QA-Large-Dark-Completion")
        app.buttons["addReflection"].tap()
        fill(app, "A specific example helps me explain my experience clearly.")
        XCTAssertTrue(app.buttons["saveReflection"].isHittable)
        capture(app, "QA-Large-Dark-Reflection")
        app.buttons["saveReflection"].tap()
        createStep(app, "Write one example from my experience.")
        for _ in 0..<8 where !app.buttons["viewJourney"].isHittable { app.swipeUp() }
        XCTAssertTrue(app.buttons["viewJourney"].isHittable)
        app.buttons["viewJourney"].tap()
        XCTAssertTrue(app.staticTexts["Read a developer role description."].waitForExistence(timeout: 8))
        capture(app, "QA-Large-Dark-Journey")
        try app.performAccessibilityAudit(for: [.contrast, .hitRegion, .sufficientElementDescription])
    }

    func testOutsideTapDismissesKeyboardWithoutConsumingEditingOrSave() {
        let app = launch()
        app.buttons["getStarted"].tap()
        fill(app, "Write a book.")
        verifyOutsideTap(app, heading: "What are you moving toward?")
        app.buttons["continueVision"].tap()
        fill(app, "Write one paragraph.")
        verifyOutsideTap(app, heading: "What’s your next step?")
        app.buttons["saveStep"].tap()
        XCTAssertTrue(app.buttons["activeStep"].waitForExistence(timeout: 8))
        app.buttons["visionSummary"].tap()
        verifyOutsideTap(app, heading: "What are you moving toward?")
        app.buttons["saveVision"].tap()
        app.buttons["activeStep"].tap()
        app.buttons["editStep"].tap()
        verifyOutsideTap(app, heading: "Edit Next Step")
        app.buttons["saveStep"].tap()
        complete(app)
        app.buttons["addReflection"].tap()
        fill(app, "Starting small helped.")
        verifyOutsideTap(app, heading: "What did you learn?")
        app.buttons["saveReflection"].tap()
        fill(app, "Write the next paragraph.")
        verifyOutsideTap(app, heading: "Keep moving.")
        app.buttons["saveStep"].tap()
        XCTAssertTrue(app.buttons["activeStep"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.buttons["activeStep"].label.contains("Write the next paragraph."))
    }

    private func verifyOutsideTap(_ app: XCUIApplication, heading: String) {
        let input = app.descendants(matching: .any).matching(identifier: "statementInput").firstMatch
        XCTAssertTrue(input.waitForExistence(timeout: 8))
        input.tap()
        XCTAssertTrue(app.keyboards.firstMatch.waitForExistence(timeout: 5))
        let original = input.value as? String
        input.tap()
        XCTAssertTrue(app.keyboards.firstMatch.exists, "Tapping the input must keep the keyboard open")
        guard let visibleHeading = app.staticTexts.matching(identifier: heading)
            .allElementsBoundByIndex.last(where: { $0.isHittable }) else {
            XCTFail("Missing visible editor heading: \(heading)")
            return
        }
        visibleHeading.tap()
        let hidden = expectation(for: NSPredicate(format: "exists == false"), evaluatedWith: app.keyboards.firstMatch)
        wait(for: [hidden], timeout: 5)
        XCTAssertEqual(input.value as? String, original, "Dismissing must preserve the draft")
        XCTAssertFalse(app.buttons["Done"].exists)
        // Leave the keyboard open: the caller's Save/Continue must work on one tap.
        input.tap()
        XCTAssertTrue(app.keyboards.firstMatch.waitForExistence(timeout: 5))
    }

    private func launch(largeText: Bool = false) -> XCUIApplication {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments = ["--ui-test-store", UUID().uuidString, "-AppleLanguages", "(en)", "-AppleLocale", "en_AU"]
        if largeText { app.launchArguments += ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL", "--ui-test-dark"] }
        app.launch()
        XCTAssertTrue(app.buttons["getStarted"].waitForExistence(timeout: 10))
        return app
    }
    private func createVision(_ app: XCUIApplication) {
        app.buttons["getStarted"].tap()
        fill(app, "Become a software engineer in Australia.")
        app.buttons["continueVision"].tap()
    }
    private func createStep(_ app: XCUIApplication, _ text: String) {
        fill(app, text)
        app.buttons["saveStep"].tap()
        XCTAssertTrue(app.buttons["activeStep"].waitForExistence(timeout: 8))
    }
    private func complete(_ app: XCUIApplication) {
        app.buttons["activeStep"].tap()
        XCTAssertTrue(app.buttons["completeStep"].waitForExistence(timeout: 8))
        app.buttons["completeStep"].tap()
        XCTAssertTrue(app.buttons["addReflection"].waitForExistence(timeout: 8))
    }
    private func fill(_ app: XCUIApplication, _ text: String) {
        let input = app.descendants(matching: .any).matching(identifier: "statementInput").firstMatch
        XCTAssertTrue(input.waitForExistence(timeout: 8))
        input.tap()
        input.typeText(text)
    }
    private func capture(_ app: XCUIApplication, _ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
