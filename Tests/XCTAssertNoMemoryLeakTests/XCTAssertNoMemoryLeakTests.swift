import XCTest
@testable import XCTAssertNoMemoryLeak

final class XCTAssertNoMemoryLeakTests: XCTestCase {
    func testAssertNoMemoryLeak() {
        class NoMemoryLeakObject {
            var id: Int = 0
            var name: String = "name"
            var children: [NoMemoryLeakObject] = []
        }
        AssertNoMemoryLeak({ return NoMemoryLeakObject() }(), assert: { message, _, _  in XCTFail(message) })
    }

    static var allTests = [
        ("testAssertNoMemoryLeak", testAssertNoMemoryLeak),
    ]
}
