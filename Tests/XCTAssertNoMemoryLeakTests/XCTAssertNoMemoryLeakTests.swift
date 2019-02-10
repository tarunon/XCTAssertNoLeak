import XCTest
@testable import XCTAssertNoMemoryLeak

final class XCTAssertNoMemoryLeakTests: XCTestCase {
    func assertMessages(_ object: @autoclosure () -> AnyObject) -> [String] {
        var result = [String]()
        assertNoMemoryLeak(object(), assert: { message, _, _ in result.append(message) })
        return result
    }
    
    func testAssertNoMemoryLeak() {
        class NoMemoryLeakObject {
            var id: Int = 0
            var name: String = "name"
            var children: [NoMemoryLeakObject] = []
        }
        XCTAssertEqual(
            assertMessages(NoMemoryLeakObject()),
            []
        )
    }
    
    func testAssertMemoryLeak() {
        class MemoryLeakObject {
            var strongSelf: MemoryLeakObject!
            init() { strongSelf = self }
        }
        XCTAssertEqual(
            assertMessages(MemoryLeakObject()),
            [makeAssertMessage(path: "self")]
        )
    }
    
    func testAssertWeakDelegate() {
        class ChildObject {
            weak var delegate: ParentObject?
        }
        class ParentObject {
            var child: ChildObject
            
            init() {
                child = ChildObject()
                child.delegate = self
            }
        }
        XCTAssertEqual(
            assertMessages(ParentObject()),
            []
        )
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
        XCTAssertEqual(
            assertMessages(ParentObject()),
            [
                makeAssertMessage(path: "self"),
                makeAssertMessage(path: "self.child")
            ]
        )
    }
    
    func testAssertOptionalProperty() {
        class ChildObject {
            var delegate: ParentObject?
        }
        class ParentObject {
            var child: ChildObject?
            
            init() {
                child = ChildObject()
                child?.delegate = self
            }
        }
        XCTAssertEqual(
            assertMessages(ParentObject()),
            [
                makeAssertMessage(path: "self"),
                makeAssertMessage(path: "self.child?")
            ]
        )
    }
    
    func testAssertLazyProperty() {
        class ChildObject {
            var delegate: ParentObject?
        }
        class ParentObject {
            lazy var child: ChildObject = ChildObject()
            
            init() {
                child.delegate = self
            }
        }
        XCTAssertEqual(
            assertMessages(ParentObject()),
            [
                makeAssertMessage(path: "self"),
                makeAssertMessage(path: "self.child")
            ]
        )
    }

    static var allTests = [
        ("testAssertNoMemoryLeak", testAssertNoMemoryLeak),
        ("testAssertMemoryLeak", testAssertMemoryLeak),
        ("testAssertWeakDelegate", testAssertWeakDelegate),
        ("testAssertStrongDelegate", testAssertStrongDelegate),
        ("testAssertOptionalProperty", testAssertOptionalProperty),
        ("testAssertLazyProperty", testAssertLazyProperty),
    ]
}
