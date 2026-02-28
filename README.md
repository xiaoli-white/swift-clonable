# SwiftClonable

A Swift macro that provides automatic cloning functionality for structs.

## Overview

SwiftClonable is a Swift Package that uses macros to automatically generate `clone()` methods for structs. It supports both deep and shallow cloning strategies and provides the `Clonable` protocol with extensions for common Swift types.

## Features

- Automatic `clone()` method generation via `@Clonable` macro
- Deep and shallow cloning support via `@Clone` attribute
- Pre-built `Clonable` implementations for Swift standard library types

## Installation

Add SwiftClonable to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/xiaoli-white/swift-clonable.git", from: "1.0.4")
]
```

## Usage

### Basic Usage

Apply the `@Clonable` macro to a struct:

```swift
import SwiftClonable

@Clonable
struct Person {
    var name: String
    var age: Int
}

let person = Person(name: "John", age: 30)
let cloned = person.clone()
// cloned: Person(name: "John", age: 30)
```

### Deep vs Shallow Cloning

By default, `@Clonable` performs shallow cloning. You can customize the cloning strategy for individual properties using the `@Clone` attribute:

```swift
@Clonable
struct User {
    @Clone(strategy: .shallow)
    var preferences: Preferences
    
    @Clone(strategy: .deep)
    var profile: Profile
}
```

### Cloning Strategy

- `.deep`: Recursively clones all nested objects
- `.shallow` (default): Creates a shallow copy (reference type properties are not cloned)

### Built-in Types

`Clonable` is already implemented for:

- `String`, `Int`, `Double`, `Float`, `Bool`
- `Optional<T>` (where T: Clonable)
- `Array<T>` (where T: Clonable)
- `Dictionary<K, V>` (where K: Clonable, V: Clonable)
- `Set<T>` (where T: Clonable)
- `OrderedDictionary<K, V>` (from swift-collections)

## Requirements

- Swift 6.2+
- swift-syntax 602.0.0+
- swift-collections 1.3.0+(Optional)

## License

MIT
