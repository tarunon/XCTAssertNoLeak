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
    case optional
    
    var description: String {
        switch self {
        case .index(let index): return "[\(index)]"
        case .label(let label): return ".\(label)"
        case .optional: return "?"
        }
    }
    
    var lazyPath: Path? {
        switch self {
        case .label(let label) where label.hasSuffix(".storage"):
            return Path.label(label.replacingOccurrences(of: ".storage", with: ""))
        default:
            return nil
        }
    }
    
    init(from keyPath: AnyKeyPath) {
        self = .label(keyPath._kvcKeyPathString!)
    }
}

extension Array where Element == Path {
    func pathString(with topObjectName: String) -> String {
        return topObjectName + self.map { $0.description }.joined()
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
        if let object = object as? OptionalKind {
            if let value = object.optional, let node = Node(from: value, discoveredObject: &discoveredObject) {
                children = [Path.optional: node]
            } else {
                children = [:]
            }
        } else {
            self.children = Dictionary(
                uniqueKeysWithValues: mirror.children
                    .enumerated()
                    .compactMap { (index, child) in
                        let path = child.label.map { Path.label($0) } ?? Path.index(index)
                        if let lazyPath = path.lazyPath {
                            guard let value = (child.value as? OptionalKind)?.optional, let node = Node(from: value, discoveredObject: &discoveredObject) else { return nil }
                            return (lazyPath, node)
                        } else {
                            guard let node = Node(from: child.value, discoveredObject: &discoveredObject) else { return nil }
                            return (path, node)
                        }
                    } + ((object as? CustomTraversable).map { object in
                        object.customTraverseKeyPaths.compactMap { keyPath in
                            let path = Path.init(from: keyPath)
                            guard let value = object[keyPath: keyPath], let node = Node(from: value, discoveredObject: &discoveredObject) else { return nil }
                            return (path, node)
                        }
                    } ?? [])
            )
        }
    }
    
    static func filterValueType(_ value: Any) -> AnyObject? {
        guard type(of: value) is AnyObject.Type else { return nil }
        return value as AnyObject
    }
    
    func leakedObjectPaths() -> [[Path]] {
        var isLeaked: Bool {
            if let customTraversable = (object as? CustomTraversable), customTraversable.ignoreAssertion {
                return false
            }
            return object != nil
        }
        return (isLeaked ? [[]] : []) +
            children.flatMap { (path, node) in
                return node.leakedObjectPaths().map { [path] + $0 }
        }
    }
    
    func allPaths() -> [[Path]] {
        return [[]] + children.flatMap { path, node in
            return node.allPaths().map { [path] + $0 }
        }
    }
}
