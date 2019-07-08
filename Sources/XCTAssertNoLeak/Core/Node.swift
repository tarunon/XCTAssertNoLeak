//
//  Node.swift
//  XCTAssertNoLeak
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
        #if swift(>=5.1)
        switch self {
        case .label(let label) where label.hasPrefix("$__lazy_storage_$_"):
            return Path.label(label.replacingOccurrences(of: "$__lazy_storage_$_", with: ""))
        default:
            return nil
        }
        #else
        switch self {
        case .label(let label) where label.hasSuffix(".storage"):
            return Path.label(label.replacingOccurrences(of: ".storage", with: ""))
        default:
            return nil
        }
        #endif
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

class Node {
    weak var object: AnyObject?
    var children: [Path: Node]
    
    convenience init(from object: Any) {
        var discoveredObject = Set<ObjectIdentifier>()
        self.init(from: object, discoveredObject: &discoveredObject)!
    }
    
    init?(from object: Any, discoveredObject: inout Set<ObjectIdentifier>) {
        self.object = Node.getReferenceValue(object)
        if let object = self.object {
            if discoveredObject.contains(ObjectIdentifier(object)) { return nil }
            discoveredObject.insert(ObjectIdentifier(object))
            
            if object is NSCopying {
                self.object = nil
            }
        }
        let mirror = Mirror(reflecting: object)
        if let object = object as? OptionalKind {
            if let value = object.optional, let node = Node(from: value, discoveredObject: &discoveredObject) {
                children = [Path.optional: node]
            } else {
                children = [:]
            }
        } else {
            let childNodesFromMirror = mirror.children
                .enumerated()
                .compactMap { (index, mirrorChild) in
                    Node.childNode(index: index, mirrorChild: mirrorChild, discoveredObject: &discoveredObject)
            }
            let childNodesFromCustomTraversable = (object as? CustomTraversable)?
                .customTraverseKeyPaths
                .compactMap { keyPath in
                    Node.childNode(object: object, keyPath: keyPath, discoveredObject: &discoveredObject)
                } ?? []
            self.children = Dictionary(
                uniqueKeysWithValues:  childNodesFromMirror + childNodesFromCustomTraversable
            )
        }
    }
    
    static func childNode(index: Int, mirrorChild: Mirror.Child, discoveredObject: inout Set<ObjectIdentifier>) -> (Path, Node)? {
        let path = mirrorChild.label.map { Path.label($0) } ?? Path.index(index)
        if let lazyPath = path.lazyPath {
            guard let value = (mirrorChild.value as? OptionalKind)?.optional, let node = Node(from: value, discoveredObject: &discoveredObject) else { return nil }
            return (lazyPath, node)
        } else {
            guard let node = Node(from: mirrorChild.value, discoveredObject: &discoveredObject) else { return nil }
            return (path, node)
        }
    }
    
    static func childNode(object: Any, keyPath: AnyKeyPath, discoveredObject: inout Set<ObjectIdentifier>) -> (Path, Node)? {
        let path = Path.init(from: keyPath)
        guard let value = object[keyPath: keyPath], let node = Node(from: value, discoveredObject: &discoveredObject) else { return nil }
        return (path, node)
    }
    
    static func getReferenceValue(_ value: Any) -> AnyObject? {
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
        return isLeaked ? [[]] : children.flatMap { (path, node) in
            return node.leakedObjectPaths().map { [path] + $0 }
        }
    }
    
    func allPaths() -> [[Path]] {
        return [[]] + children.flatMap { path, node in
            return node.allPaths().map { [path] + $0 }
        }
    }

    func intervalForFreeing() -> TimeInterval {
        return children.values.reduce((object as? CustomTraversable)?.intervalForFreeing ?? 0.0, { $0 + $1.intervalForFreeing() })
    }
    
    func assertMessage() -> String? {
        let paths = leakedObjectPaths()
        if paths.isEmpty { return nil }
        return "\(paths.count) object occured memory leak." + "\n" + paths.map { "- \($0.pathString(with: "self"))" }.joined(separator: "\n")
    }
}
