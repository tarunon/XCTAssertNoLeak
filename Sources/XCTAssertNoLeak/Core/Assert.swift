//
//  Assert.swift
//  XCTAssertNoLeak
//
//  Created by tarunon on 2019/02/10.
//

import Foundation

func makeAssertMessage(path: String) -> String {
    return "Leaked Object Found: \(path)"
}

func assertNoLeak(_ object: @autoclosure () -> AnyObject, assert: (String, StaticString, UInt) -> (), file: StaticString, line: UInt) {
    var node: Node!
    autoreleasepool {
        var strongObject: AnyObject! = object()
        node = Node(from: strongObject!)
        strongObject = nil
    }
    node.leakedObjectPaths().forEach { (path) in
        assert(makeAssertMessage(path: path.pathString(with: "self")), file, line)
    }
}

func assertNoLeak(_ f: (Context) -> (), assert: @escaping (String, StaticString, UInt) -> (), file: StaticString, line: UInt) {
    struct Element {
        var name: String
        var node: Node
        var file: StaticString
        var line: UInt
    }
    var nodes: [Element] = []
    autoreleasepool {
        var completed = false
        f(Context(traverse: {
            nodes.append(Element(name: $0, node: Node(from: $1), file: $2, line: $3))
        }, completion: {
            completed = true
        }, assert: assert, file: file, line: line))
        while !completed {
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.01))
        }
    }
    nodes.forEach { element in
        element.node.leakedObjectPaths().forEach { path in
            assert(makeAssertMessage(path: path.pathString(with: element.name)), element.file, element.line)
        }
    }
}
