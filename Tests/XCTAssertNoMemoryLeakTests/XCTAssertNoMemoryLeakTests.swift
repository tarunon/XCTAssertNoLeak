import XCTest
@testable import XCTAssertNoMemoryLeak

final class XCTAssertNoMemoryLeakTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(XCTAssertNoMemoryLeak().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
