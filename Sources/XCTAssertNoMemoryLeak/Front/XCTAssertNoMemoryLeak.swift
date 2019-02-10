import XCTest

public func XCTAssertNoMemoryLeak(_ object: @autoclosure () -> AnyObject, file: String = #file, line: UInt = #line) {
    assertNoMemoryLeak(object(), assert: XCTFail)
}
