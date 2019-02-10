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
    
    static var allTests = [
        ("testFilterValueType", testFilterValueType),
    ]
}
