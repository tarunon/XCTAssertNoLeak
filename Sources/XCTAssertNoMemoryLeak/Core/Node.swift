//
//  Node.swift
//  XCTAssertNoMemoryLeak
//
//  Created by tarunon on 2019/02/10.
//

import Foundation

enum Path: Hashable, CustomStringConvertible {
    case index(Int)
    case label(String)
    
    var description: String {
        switch self {
        case .index(let index): return "[\(index)]"
        case .label(let label): return ".\(label)"
        }
    }
}

extension Array where Element == Path {
    var pathPrint: String {
        return "self" + self.map { $0.description }.joined()
    }
}

protocol OptionalKind {
    var optional: Any? { get }
}

extension Optional: OptionalKind {
    var optional: Any? {
        return self.map { $0 }
    }
}

protocol DictionaryKind {
    var dictionary: [String: Any] { get }
}

extension Dictionary: DictionaryKind where Key == String {
    var dictionary: [String : Any] {
        return self.mapValues { $0 }
    }
}

class Node {
    weak var object: AnyObject?
    var children: [Path: Node]
    
    init(from object: Any) {
        self.object = Node.filterValueType(object)
        let mirror = Mirror(reflecting: object)
        self.children = Dictionary(
            uniqueKeysWithValues: mirror.children
                .enumerated()
                .map { (index, child) in
                    let path = child.label.map { Path.label($0) } ?? Path.index(index)
                    let node = Node(from: child.value)
                    return (path, node)
        })
    }
    
    static func filterValueType(_ value: Any) -> AnyObject? {
        guard type(of: value) is AnyObject.Type else { return nil }
        return value as AnyObject
    }
    
    static func unwrapOptionalValue(_ value: Any) -> Any? {
        if let kind = value as? OptionalKind {
            guard let value = kind.optional else { return nil }
            return unwrapOptionalValue(value)
        } else {
            return value
        }
    }
    
    func leakedObjectPaths() -> [[Path]] {
        if object != nil {
            return [[]]
        }
        return children.flatMap { (path, node) in
            return node.leakedObjectPaths().map { $0 + [path] }
        }
    }
}
