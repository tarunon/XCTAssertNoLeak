import XCTest
@testable import XCTAssertNoMemoryLeak

final class XCTAssertNoMemoryLeakTests: XCTestCase {
    func testAssertNoMemoryLeak() {
        class NoMemoryLeakObject {
            var id: Int = 0
            var name: String = "name"
            var children: [NoMemoryLeakObject] = []
        }
        assertNoMemoryLeak({ return NoMemoryLeakObject() }(), assert: { message, _, _  in
            XCTFail("should not call assert if no memory leak")
        })
    }
    
    func testAssertMemoryLeak() {
        class MemoryLeakObject {
            var strongSelf: MemoryLeakObject!
            init() { strongSelf = self }
        }
        assertNoMemoryLeak({ return MemoryLeakObject() }(), assert: { message, _, _  in
            XCTAssertEqual(message, makeAssertMessage([]))
        })
    }

    static var allTests = [
        ("testAssertNoMemoryLeak", testAssertNoMemoryLeak),
    ]
}
