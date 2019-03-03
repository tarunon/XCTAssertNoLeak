import XCTest
@testable import XCTAssertNoMemoryLeak

#if os(iOS)
extension UIView: CustomTraversable {
    public var customTraverseKeyPaths: [AnyKeyPath] {
        return [
            \UIView.subviews
        ]
    }
}
#endif

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
        XCTAssertEqual(
            node.allPaths(),
            [
                [],
                [Path.label("value")],
                [Path.label("value"), Path.optional]
            ]
        )
    }
    
    func testLazyPropertyPath() {
        class Foo {
            lazy var value = 1
        }
        let foo = Foo()
        _ = foo.value
        let node = Node(from: foo)
        XCTAssertEqual(
            node.allPaths(),
            [
                [],
                [Path.label("value")]
            ]
        )
    }
    
    #if os(iOS)
    func testCustomTraverse() {
        let view1 = UIView()
        let view2 = UIView()
        let view3 = UIView()
        view1.addSubview(view2)
        view2.addSubview(view3)
        let node = Node(from: view1)
        XCTAssertEqual(
            node.allPaths(),
            [
                [],
                [Path.label("subviews")],
                [Path.label("subviews"), Path.index(0)],
                [Path.label("subviews"), Path.index(0), Path.label("subviews")],
                [Path.label("subviews"), Path.index(0), Path.label("subviews"), Path.index(0)],
                [Path.label("subviews"), Path.index(0), Path.label("subviews"), Path.index(0), Path.label("subviews")],
            ]
        )
    }
    #endif
    
    static var allTests = [
        ("testFilterValueType", testFilterValueType),
        ("testOptionalPath", testOptionalPath),
        ("testLazyPropertyPath", testLazyPropertyPath),
    ]
}
