import XCTest
@testable import XCTAssertNoLeak

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
    func testGetReferenceValue() {
        class Foo { }
        let object: Any = Foo()
        if let unwrapped = Node.getReferenceValue(object) {
            XCTAssertTrue(type(of: unwrapped) is Foo.Type)
        } else {
            XCTFail()
        }
        
        let value: Any = 1
        if Node.getReferenceValue(value) != nil {
            XCTFail()
        }

        let optional = Optional(Foo()) as Any
        if Node.getReferenceValue(optional) != nil {
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
    
    func testImplicitlyUnwrappedOptionalPath() {
        class Foo {
            var value: Int! = 1
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
        ("testGetReferenceValue", testGetReferenceValue),
        ("testOptionalPath", testOptionalPath),
        ("testLazyPropertyPath", testLazyPropertyPath),
    ]
}
