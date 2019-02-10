//
//  Assert.swift
//  XCTAssertNoMemoryLeak
//
//  Created by tarunon on 2019/02/10.
//

import Foundation

func makeAssertMessage(_ path: [Path]) -> String {
    return "Leaked Object Found: \(path.pathPrint)"
}

func assertNoMemoryLeak(_ object: @autoclosure () -> AnyObject, assert: (String, StaticString, UInt) -> (), file: StaticString = #file, line: UInt = #line) {
    var node: Node!
    autoreleasepool {
        var strongObject: AnyObject! = object()
        node = Node(from: strongObject!)
        strongObject = nil
    }
    node.leakedObjectPaths().forEach { (path) in
        assert(makeAssertMessage(path), file, line)
    }
}
