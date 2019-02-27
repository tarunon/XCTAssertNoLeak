import XCTest
@testable import XCTAssertNoMemoryLeak

final class XCTAssertNoMemoryLeakTests: XCTestCase {
    func assertMessages(_ object: @autoclosure () -> AnyObject) -> [String] {
        var result = [String]()
        assertNoMemoryLeak(object(), assert: { message, _, _ in result.append(message) }, file: "", line: 0)
        return result
    }
    
    func assertMessages(_ f: @escaping (Context) -> ()) -> [String] {
        var result = [String]()
        assertNoMemoryLeak(f, assert: { message, _, _ in result.append(message) }, file: "", line: 0)
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
            var strongDelegate: ParentObject?
        }
        class ParentObject {
            var child: ChildObject?
            
            init() {
                child = ChildObject()
                child?.strongDelegate = self
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
            var strongDelegate: ParentObject?
        }
        class ParentObject {
            lazy var child: ChildObject = ChildObject()
            
            init() {
                child.strongDelegate = self
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
    
    func testAssertClosure() {
        class View {
            var strongDelegate: AnyObject?
        }
        class ViewController {
            lazy var view: View = loadView()
            func loadView() -> View {
                let view = View()
                view.strongDelegate = self
                return view
            }
        }
        XCTAssertEqual(
            assertMessages { context in
                let vc = ViewController()
                context.traverse(name: "vc", object: vc)
            },
            ["Context.completion() must call"]
        )
        XCTAssertEqual(
            assertMessages { context in
                let vc = ViewController()
                context.traverse(name: "vc", object: vc)
                context.completion()
            },
            []
        )
        XCTAssertEqual(
            assertMessages { context in
                let vc = ViewController()
                _ = vc.view // load view
                context.traverse(name: "vc", object: vc)
                context.completion()
            },
            [
                makeAssertMessage(path: "vc"),
                makeAssertMessage(path: "vc.view")
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
        ("testAssertClosure", testAssertClosure),
    ]
}
