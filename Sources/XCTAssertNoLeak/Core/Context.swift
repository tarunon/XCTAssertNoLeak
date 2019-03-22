//
//  Context.swift
//  XCTAssertNoLeak
//
//  Created by tarunon on 2019/02/17.
//

import Foundation

/// Asynchronous memory leak test context.
/// Register assert target using `traverse(name:object:)`.
/// Must call `completion()` when sure all object should be dealocated.
public final class Context {
    var completed = false
    var _traverse: (String, AnyObject, StaticString, UInt) -> ()
    var _completion: () -> ()
    var _assert: (String, StaticString, UInt) -> ()
    var file: StaticString
    var line: UInt

    init(traverse: @escaping (String, AnyObject, StaticString, UInt) -> (), completion: @escaping () -> (), assert: @escaping (String, StaticString, UInt) -> (), file: StaticString, line: UInt) {
        self.file = file
        self.line = line
        self._assert = assert
        self._traverse = traverse
        self._completion = completion
    }
    
    /// Traverse assert target object.
    ///
    /// - Parameters:
    ///   - name: The object name. If the object leaked, assert message will show using this name.
    ///   - object: The assert target.
    public func traverse(name: String, object: AnyObject, file: StaticString=#file, line: UInt=#line) {
        _traverse(name, object, file, line)
    }
    
    /// Call this closure when sure all object dealocated.
    public func completion() {
        completed = true
        _completion()
    }
    
    deinit {
        if !completed {
            _assert("context.completion() must call", file, line)
        }
        _completion()
    }
}
