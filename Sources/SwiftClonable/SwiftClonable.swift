public protocol Clonable {
    func clone() -> Self
}

@attached(extension, conformances: Clonable, names: named(clone))
public macro Clonable(autoClone: Bool = true) =
    #externalMacro(
        module: "SwiftClonableMacros",
        type: "ClonableMacro"
    )

@attached(peer)
public macro Clone(strategy: CloneStrategy = .deep) =
    #externalMacro(
        module: "SwiftClonableMacros",
        type: "CloneMacro"
    )

public enum CloneStrategy {
    case deep
    case shallow
    case custom(() -> Any)
}

extension String: Clonable {
    public func clone() -> String {
        return self
    }
}

extension Int: Clonable {
    public func clone() -> Int { return self }
}

extension Double: Clonable {
    public func clone() -> Double { return self }
}

extension Float: Clonable {
    public func clone() -> Float { return self }
}

extension Bool: Clonable {
    public func clone() -> Bool { return self }
}

extension Optional: Clonable where Wrapped: Clonable {
    public func clone() -> Self {
        switch self {
        case .some(let value):
            return .some(value.clone())
        case .none:
            return .none
        }
    }
}

extension Array: Clonable where Element: Clonable {
    public func clone() -> [Element] {
        return map { $0.clone() }
    }
}

extension Dictionary: Clonable where Key: Clonable, Value: Clonable {
    public func clone() -> [Key: Value] {
        var result: [Key: Value] = [:]
        for (key, value) in self {
            result[key.clone()] = value.clone()
        }
        return result
    }
}

extension Set: Clonable where Element: Clonable {
    public func clone() -> Set<Element> {
        return Set(map { $0.clone() })
    }
}

#if canImport(Collections)
    import Collections
    extension OrderedDictionary: Clonable where Key: Clonable, Value: Clonable {
        public func clone() -> OrderedDictionary<Key, Value> {
            var result: OrderedDictionary<Key, Value> = [:]
            for (key, value) in self {
                result[key.clone()] = value.clone()
            }
            return result
        }
    }
#endif
