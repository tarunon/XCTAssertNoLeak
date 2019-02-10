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
    
    convenience init(from object: Any) {
        var discoveredObject = Set<ObjectIdentifier>()
        self.init(from: object, discoveredObject: &discoveredObject)!
    }
    
    init?(from object: Any, discoveredObject: inout Set<ObjectIdentifier>) {
        self.object = Node.filterValueType(object)
        if let object = self.object {
            if discoveredObject.contains(ObjectIdentifier(object)) { return nil }
            discoveredObject.insert(ObjectIdentifier(object))
        }
        let mirror = Mirror(reflecting: object)
        self.children = Dictionary(
            uniqueKeysWithValues: mirror.children
                .enumerated()
                .compactMap { (index, child) in
                    let path = child.label.map { Path.label($0) } ?? Path.index(index)
                    guard let node = Node(from: child.value, discoveredObject: &discoveredObject) else { return nil}
                    return (path, node)
        })
    }
    
    static func filterValueType(_ value: Any) -> AnyObject? {
        guard type(of: value) is AnyObject.Type else { return nil }
        return value as AnyObject
    }
    
    func leakedObjectPaths() -> [[Path]] {
        return (object != nil ? [[]] : []) +
            children.flatMap { (path, node) in
                return node.leakedObjectPaths().map { $0 + [path] }
        }
    }
}
