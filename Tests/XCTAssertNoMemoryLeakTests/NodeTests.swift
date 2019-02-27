import XCTest
@testable import XCTAssertNoMemoryLeak

final class NodeTests: XCTestCase {
    func testFilterValueType() {
        class Foo { }
        let object: Any = Foo()
        if let unwrapped = Node.filterValueType(object) {
            XCTAssertTrue(type(of: unwrapped) is Foo.Type)
        } else {
            XCTFail()
        }
        
        let value: Any = 1
        if Node.filterValueType(value) != nil {
            XCTFail()
        }
    }
    
    func testOptionalPath() {
        class Foo {
            var value: Int? = 1
        }
        let node = Node(from: Foo())
        XCTAssertEqual(node.allPaths(), [[],[Path.label("value")], [Path.label("value"), Path.optional]])
    }
    
    func testLazyPropertyPath() {
        class Foo {
            lazy var value = 1
        }
        let foo = Foo()
        _ = foo.value
        let node = Node(from: foo)
        XCTAssertEqual(node.allPaths(), [[],[Path.label("value")]])
    }
    
    static var allTests = [
        ("testFilterValueType", testFilterValueType),
        ("testOptionalPath", testOptionalPath),
        ("testLazyPropertyPath", testLazyPropertyPath),
    ]
}
