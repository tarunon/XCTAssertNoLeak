import XCTest
@testable import XCTAssertNoMemoryLeak

final class XCTAssertNoMemoryLeakTests: XCTestCase {
    func testAssertNoMemoryLeak() {
        class NoMemoryLeakObject {
            var id: Int = 0
            var name: String = "name"
            var children: [NoMemoryLeakObject] = []
        }
        assertNoMemoryLeak(NoMemoryLeakObject(), assert: { message, _, _  in
            XCTFail("should not call assert if no memory leak")
        })
    }
    
    func testAssertMemoryLeak() {
        class MemoryLeakObject {
            var strongSelf: MemoryLeakObject!
            init() { strongSelf = self }
        }
        assertNoMemoryLeak(MemoryLeakObject(), assert: { message, _, _  in
            XCTAssertEqual(message, makeAssertMessage([]))
        })
    }
    
    func testAssertStrongDelegate() {
        class ChildObject {
            var delegate: ParentObject?
        }
        class ParentObject {
            var child: ChildObject
            
            init() {
                child = ChildObject()
                child.delegate = self
            }
        }
        var result = [String]()
        assertNoMemoryLeak(ParentObject(), assert: { message, _, _ in
            result.append(message)
        })
        XCTAssertEqual(
            result,
            [
                makeAssertMessage([]),
                makeAssertMessage([.label("child")])
            ]
        )
    }

    static var allTests = [
        ("testAssertNoMemoryLeak", testAssertNoMemoryLeak),
    ]
}
