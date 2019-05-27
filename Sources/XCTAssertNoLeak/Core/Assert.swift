//
//  Assert.swift
//  XCTAssertNoLeak
//
//  Created by tarunon on 2019/02/10.
//

import Foundation

func assertNoLeak(_ object: @autoclosure () -> AnyObject, assert: (String, StaticString, UInt) -> (), file: StaticString, line: UInt) {
    var node: Node!
    autoreleasepool {
        var strongObject: AnyObject! = object()
        node = Node(from: strongObject!)
        strongObject = nil
    }
    RunLoop.current.run(until: Date(timeIntervalSinceNow: node.intervalForFreeing()))
    if let assertMessage = node.assertMessage("self") {
        assert(assertMessage, file, line)
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
    RunLoop.current.run(until: Date(timeIntervalSinceNow: nodes.reduce(TimeInterval(0.0), { $0 + $1.node.intervalForFreeing() })))
    nodes.forEach { element in
        if let assertMessage = element.node.assertMessage(element.name) {
            assert(assertMessage, element.file, element.line)
        }
    }
}
