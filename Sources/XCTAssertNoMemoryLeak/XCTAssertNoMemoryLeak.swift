import XCTest

func AssertNoMemoryLeak(_ object: @autoclosure () -> AnyObject, assert: (String, StaticString, UInt) -> (), file: StaticString = #file, line: UInt = #line) {
    var node: Node!
    autoreleasepool {
        var strongObject: AnyObject! = object()
        node = Node(from: strongObject)
        strongObject = nil
    }
    node.leakedObjectPaths().forEach { (path) in
        assert("Memory Leak found: \(path.pathPrint)", file, line)
    }
}

public func XCTAssertNoMemoryLeak(_ object: @autoclosure () -> AnyObject, file: String = #file, line: UInt = #line) {
    AssertNoMemoryLeak(object(), assert: XCTFail)
}
