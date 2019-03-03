import XCTest

public func XCTAssertNoLeak(_ object: @autoclosure () -> AnyObject, file: StaticString = #file, line: UInt = #line) {
    assertNoLeak(object(), assert: XCTFail, file: file, line: line)
}

public func XCTAssertNoLeak(_ f: (Context) -> (), file: StaticString = #file, line: UInt = #line) {
    assertNoLeak(f, assert: XCTFail, file: file, line: line)
}
