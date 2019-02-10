//
//  Assert.swift
//  XCTAssertNoMemoryLeak
//
//  Created by tarunon on 2019/02/10.
//

import Foundation

func makeAssertMessage(path: String) -> String {
    return "Leaked Object Found: \(path)"
}

func assertNoMemoryLeak(_ object: @autoclosure () -> AnyObject, assert: (String, StaticString, UInt) -> (), file: StaticString = #file, line: UInt = #line) {
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
