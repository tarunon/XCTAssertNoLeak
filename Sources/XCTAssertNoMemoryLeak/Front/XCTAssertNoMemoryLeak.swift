import XCTest

public func XCTAssertNoMemoryLeak(_ object: @autoclosure () -> AnyObject, file: StaticString = #file, line: UInt = #line) {
    assertNoMemoryLeak(object(), assert: XCTFail, file: file, line: line)
}

public func XCTAssertNoMemoryLeak(_ f: (Context) -> (), file: StaticString = #file, line: UInt = #line) {
    assertNoMemoryLeak(f, assert: XCTFail, file: file, line: line)
}
