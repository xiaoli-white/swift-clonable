# SwiftClonable

一个为结构体自动生成克隆功能的 Swift 宏包。

## 概述

SwiftClonable 是一个 Swift 包，通过宏为结构体自动生成 `clone()` 方法。支持深度克隆和浅度克隆策略，并提供了 `Clonable` 协议及其对常见 Swift 类型的扩展实现。

## 功能特性

- 通过 `@Clonable` 宏自动生成 `clone()` 方法
- 通过 `@Clone` 属性支持深度和浅度克隆策略
- 为 Swift 标准库类型预置 `Clonable` 实现

## 安装

在 `Package.swift` 中添加 SwiftClonable 依赖：

```swift
dependencies: [
    .package(url: "https://github.com/xiaoli-white/swift-clonable.git", from: "1.0.2")
]
```

## 使用方法

### 基本用法

将 `@Clonable` 宏应用于结构体：

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

### 深度克隆与浅度克隆

默认情况下，`@Clonable` 执行浅克隆。您可以使用 `@Clone` 属性为单个属性自定义克隆策略：

```swift
@Clonable
struct User {
    @Clone(strategy: .shallow)
    var preferences: Preferences
    
    @Clone(strategy: .deep)
    var profile: Profile
}
```

### 克隆策略

- `.deep`：递归克隆所有嵌套对象
- `.shallow`（默认）：创建浅拷贝（引用类型属性不会被克隆）

### 内置类型

以下类型已实现 `Clonable`：

- `String`、`Int`、`Double`、`Float`、`Bool`
- `Optional<T>`（其中 T: Clonable）
- `Array<T>`（其中 T: Clonable）
- `Dictionary<K, V>`（其中 K: Clonable, V: Clonable）
- `Set<T>`（其中 T: Clonable）
- `OrderedDictionary<K, V>`（来自 swift-collections）

## 环境要求

- Swift 6.2+
- swift-syntax 602.0.0+
- swift-collections 1.3.0+(可选)

## 许可证

MIT
