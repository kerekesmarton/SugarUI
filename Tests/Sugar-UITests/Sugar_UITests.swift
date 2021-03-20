import XCTest
@testable import Sugar_UI

final class Sugar_UITests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Sugar_UI().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
