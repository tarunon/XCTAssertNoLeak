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
    var ignoreAssertion: Bool { get }

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
    var intervalForFreeing: TimeInterval {
        return 0.0
    }
}
