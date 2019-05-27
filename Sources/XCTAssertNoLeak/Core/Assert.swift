//
//  Assert.swift
//  XCTAssertNoLeak
//
//  Created by tarunon on 2019/02/10.
//

import Foundation

func assertNoLeak(_ object: @autoclosure () -> AnyObject, assert: @escaping (String, StaticString, UInt) -> (), file: StaticString, line: UInt) {
    let context = AssertNoLeakContextInternal(assert: assert, file: file, line: line)
    context.process { (context) in
        context.traverse(object(), file: file, line: line)
        context.completion()
    }
    context.assert()
}

func assertNoLeak(_ f: (AssertNoLeakContext) -> (), assert: @escaping (String, StaticString, UInt) -> (), file: StaticString, line: UInt) {
    let context = AssertNoLeakContextInternal(assert: assert, file: file, line: line)
    context.process(f)
    context.assert()
}
