import XCTest
#if swift(>=4.2)
#if compiler(>=5.0)
/// Generates a failure if the object is leaked.
///
/// - Parameters:
///   - object: The asssert target. Should not have any other references.
public func XCTAssertNoLeak(file: StaticString = #file, line: UInt = #line, _ object: @autoclosure () -> AnyObject) {
    assertNoLeak(object(), assert: XCTFail, file: file, line: line)
}

/// Generates a failure asynchronously if traversed objects are leaked.
/// The closure is executed synchronously and blocks while running.
///
/// - Parameters:
///   - f: The closure givven memory leak test context.
///
/// ```swift
/// XCTAssertNoLeak { context in
///    let vc = MyViewController()
///    root.present(vc, animated: true) {
///       context.traverse(name: "vc", object: vc)
///       vc.dismiss(animated: true) {
///          context.completion()
///       }
///    }
/// }
/// ```
public func XCTAssertNoLeak(file: StaticString = #file, line: UInt = #line, _ f: (AssertNoLeakContext) -> ()) {
    assertNoLeak(f, assert: XCTFail, file: file, line: line)
}
#else
/// Generates a failure if the object is leaked.
///
/// - Parameters:
///   - object: The asssert target. Should not have any other references.
@available(swift, deprecated: 4.2.0, message: "XCTAssertNoLeak may not work correct: https://bugs.swift.org/browse/SR-8878")
public func XCTAssertNoLeak(file: StaticString = #file, line: UInt = #line, _ object: @autoclosure () -> AnyObject) {
    assertNoLeak(object(), assert: XCTFail, file: file, line: line)
}

/// Generates a failure asynchronously if traversed objects are leaked.
/// The closure is executed synchronously and blocks while running.
///
/// - Parameters:
///   - f: The closure givven memory leak test context.
///
/// ```swift
/// XCTAssertNoLeak { context in
///    let vc = MyViewController()
///    root.present(vc, animated: true) {
///       context.traverse(name: "vc", object: vc)
///       vc.dismiss(animated: true) {
///          context.completion()
///       }
///    }
/// }
/// ```
@available(swift, deprecated: 4.2.0, message: "XCTAssertNoLeak may not work correct: https://bugs.swift.org/browse/SR-8878")
public func XCTAssertNoLeak(file: StaticString = #file, line: UInt = #line, _ f: (Context) -> ()) {
    assertNoLeak(f, assert: XCTFail, file: file, line: line)
}
#endif
#else
/// Generates a failure if the object is leaked.
///
/// - Parameters:
///   - object: The asssert target. Should not have any other references.
public func XCTAssertNoLeak(file: StaticString = #file, line: UInt = #line, _ object: @autoclosure () -> AnyObject) {
    assertNoLeak(object(), assert: XCTFail, file: file, line: line)
}

/// Generates a failure asynchronously if traversed objects are leaked.
/// The closure is executed synchronously and blocks while running.
///
/// - Parameters:
///   - f: The closure givven memory leak test context.
///
/// ```swift
/// XCTAssertNoLeak { context in
///    let vc = MyViewController()
///    root.present(vc, animated: true) {
///       context.traverse(name: "vc", object: vc)
///       vc.dismiss(animated: true) {
///          context.completion()
///       }
///    }
/// }
/// ```
public func XCTAssertNoLeak(file: StaticString = #file, line: UInt = #line, _ f: (Context) -> ()) {
    assertNoLeak(f, assert: XCTFail, file: file, line: line)
}
#endif

