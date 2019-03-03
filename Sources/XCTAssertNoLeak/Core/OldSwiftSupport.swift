//
//  BackwardCompatibility.swift
//  XCTAssertNoLeak
//
//  Created by tarunon on 2019/03/03.
//

import Foundation

#if swift(>=4.1)
#else
extension Sequence {
    func compactMap<ElementOfResult>(transform: (Element) throws -> ElementOfResult?) rethrows -> [ElementOfResult] {
        return try flatMap(transform)
    }
}

extension Path {
    static func == (lhs: Path, rhs: Path) -> Bool {
        switch (lhs, rhs) {
        case (.index(let lhs), .index(let rhs)): return lhs == rhs
        case (.label(let lhs), .label(let rhs)): return lhs == rhs
        case (.optional, .optional): return true
        default: return false
        }
    }
    
    var hashValue: Int {
        switch self {
        case .index(let index): return index.hashValue ^ 1167359
        case .label(let label): return label.hashValue ^ 1167391
        case .optional: return 1167409
        }
    }
}
    
extension ImplicitlyUnwrappedOptional: OptionalKind {
    var optional: Any? {
        switch self {
        case .some(let wrapped): return wrapped
        case .none: return nil
        }
    }
}
#endif
