//
//  OldSwiftSupport.swift
//  XCTAssertNoLeak
//
//  Created by tarunon on 2019/03/03.
//

import XCTest

#if swift(>=4.1)
#else
struct ArrayBox<E: Equatable>: Equatable {
    var value: [E]
    
    static func == (lhs: ArrayBox<E>, rhs: ArrayBox<E>) -> Bool {
        return lhs.value == rhs.value
    }
}
func XCTAssertEqual<E: Equatable>(_ expression1: @autoclosure () -> [[E]], _ expression2: @autoclosure () -> [[E]], file: StaticString = #file, line: UInt = #line) {
    XCTAssertEqual(expression1().map(ArrayBox.init), expression2().map(ArrayBox.init))
}
#endif
