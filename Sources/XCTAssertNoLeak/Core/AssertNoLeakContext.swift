//
//  AssertNoLeakContext.swift
//  XCTAssertNoLeak
//
//  Created by tarunon on 2019/02/17.
//

import Foundation


/// Asynchronous memory leak test context.
/// Register assert target using `traverse(name:object:)`.
/// Must call `completion()` when sure all object should be dealocated.
public final class AssertNoLeakContext {
    private let internalContext: AssertNoLeakContextInternal
    
    init(internalContext: AssertNoLeakContextInternal) {
        self.internalContext = internalContext
    }
    
    /// Traverse assert target object.
    ///
    /// - Parameters:
    ///   - name: The object name. If the object leaked, assert message will show using this name.
    ///   - object: The assert target.
    public func traverse(_ object: AnyObject, file: StaticString=#file, line: UInt=#line) {
        internalContext.elements.append(.init(node: Node(from: object), file: file, line: line))
    }
    
    @available(*, deprecated, message: "`name` fieald isn't support no longer")
    public func traverse(name: String, object: AnyObject, file: StaticString=#file, line: UInt=#line) {
        internalContext.elements.append(.init(node: Node(from: object), file: file, line: line))
    }
    
    /// Call this closure when sure all object dealocated.
    public func completion() {
        internalContext.completed = true
    }
    
    deinit {
        if !internalContext.completed {
            internalContext._assert("context.completion() must call", internalContext.file, internalContext.line)
        }
        internalContext.completed = true
    }
    
}

final class AssertNoLeakContextInternal {
    let _assert: (String, StaticString, UInt) -> ()
    let file: StaticString
    let line: UInt
    var completed = false
    
    fileprivate struct Element {
        var node: Node
        var file: StaticString
        var line: UInt
    }
    
    fileprivate var elements: [Element] = []
    
    init(assert: @escaping (String, StaticString, UInt) -> (), file: StaticString, line: UInt) {
        self.file = file
        self.line = line
        self._assert = assert
    }
    
    func process(_ f: (AssertNoLeakContext) -> ()) {
        autoreleasepool {
            f(AssertNoLeakContext(internalContext: self))
            while !completed {
                RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.01))
            }
        }
        RunLoop.current.run(until: Date(timeIntervalSinceNow: elements.reduce(TimeInterval(0.0), { $0 + $1.node.intervalForFreeing() })))
    }
    
    func assert() {
        elements.forEach { element in
            guard let assertMessage = element.node.assertMessage() else { return }
            _assert(assertMessage, element.file, element.line)
        }
    }
}

@available(*, deprecated, renamed: "AssertNoLeakContext" )
public typealias Context = AssertNoLeakContext
