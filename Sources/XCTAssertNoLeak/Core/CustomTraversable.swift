//
//  CustomTraversable.swift
//  XCTAssertNoLeak
//
//  Created by tarunon on 2019/02/27.
//

import Foundation

public protocol CustomTraversable {
    /// Define keyPaths that objc properties.
    /// XCTAssertNoLeak use Swift Mirror, it can traverse swift properties, but objc properties can't.
    var customTraverseKeyPaths: [AnyKeyPath] { get }
    
    /// Ignore object assertion if memory leak happen.
    /// Set true if the object is singleton/shared object.
    /// NOTE: The children will be checked if the assertion has ignored. To ignore children too, use with ignoreChildren.
    var ignoreAssertion: Bool { get }

    /// Ignore all children and doesn't check their leak.
    /// customTraverseKeyPaths will be ignored if this set true.
    var ignoreChildren: Bool { get }

    /// Waiting interval for the object freeing.
    var intervalForFreeing: TimeInterval { get }
}

public extension CustomTraversable {
    var customTraverseKeyPaths: [AnyKeyPath] {
        return []
    }
    var ignoreAssertion: Bool {
        return false
    }
    var ignoreChildren: Bool {
        return false
    }
    var intervalForFreeing: TimeInterval {
        return 0.0
    }
}
