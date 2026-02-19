import SwiftClonable

@Clonable
struct Person: ~Copyable {
    let name: String
    let age: Int
    func toString() -> String {
        "Person(name: \(name), age: \(age))"
    }
}
func f() {
    let p = Person(name: "Xiaoli", age: 20)
    let p2 = p.clone()
    print(p.toString())
    print(p2.toString())
}
f()
