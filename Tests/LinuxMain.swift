import XCTest

import XCTAssertNoMemoryLeakTests

var tests = [XCTestCaseEntry]()
tests += XCTAssertNoMemoryLeakTests.allTests()
XCTMain(tests)