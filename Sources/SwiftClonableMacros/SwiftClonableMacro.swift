import SwiftCompilerPlugin
import SwiftParser
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct ClonableMacro: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            throw ClonableMacroError.onlyApplicableToStruct
        }
        let autoClone: Bool = {
            let arguments = node.arguments?.as(LabeledExprListSyntax.self)
            let found = arguments?.first { $0.label?.text == "autoClone" }
            let value = found?.expression.as(BooleanLiteralExprSyntax.self)
            return value.map { $0.literal.text == "true" } ?? true
        }()
        let storedProperties = getStoredProperties(from: structDecl)
        let extensionDecl = try generateExtension(
            type: type,
            properties: storedProperties,
            autoClone: autoClone
        )
        return [extensionDecl]
    }

    private static func getStoredProperties(from structDecl: StructDeclSyntax) -> [StoredProperty] {
        var properties: [StoredProperty] = []
        for member in structDecl.memberBlock.members {
            if let varDecl = member.decl.as(VariableDeclSyntax.self) {
                if isComputedProperty(varDecl) { continue }
                for binding in varDecl.bindings {
                    guard let pattern = binding.pattern.as(IdentifierPatternSyntax.self) else {
                        continue
                    }
                    let name = pattern.identifier.text
                    let type = extractTypeSafely(from: binding)
                    let strategy = extractCloneStrategy(from: varDecl)
                    properties.append(
                        StoredProperty(
                            name: name,
                            type: type,
                            strategy: strategy
                        ))
                }
            }
        }
        return properties
    }
    private static func isComputedProperty(_ varDecl: VariableDeclSyntax) -> Bool {
        for binding in varDecl.bindings {
            if binding.accessorBlock != nil { return true }
        }
        return false
    }
    private static func extractTypeSafely(from binding: PatternBindingSyntax) -> String? {
        return binding.typeAnnotation?.type.description
    }
    private static func extractCloneStrategy(from varDecl: VariableDeclSyntax) -> CloneStrategy {
        for attribute in varDecl.attributes {
            guard let attr = attribute.as(AttributeSyntax.self) else { continue }
            guard attr.attributeName.as(IdentifierTypeSyntax.self)?.name.text == "Clone" else {
                continue
            }
            if let arguments = attr.arguments?.as(LabeledExprListSyntax.self) {
                for arg in arguments {
                    if arg.label?.text == "strategy",
                        let memberAccess = arg.expression.as(MemberAccessExprSyntax.self)
                    {
                        let strategyName = memberAccess.declName.baseName.text
                        switch strategyName {
                        case "deep": return .deep
                        case "shallow": return .shallow
                        default: break
                        }
                    }
                }
            }
            return .deep
        }
        return .shallow
    }
    private static func generateExtension(
        type: some TypeSyntaxProtocol,
        properties: [StoredProperty],
        autoClone: Bool
    ) throws -> ExtensionDeclSyntax {
        let typeName = type.description
        let cloneMethod =
            if autoClone {
                {
                    let propertyClones = properties.map { property in
                        let expr =
                            switch property.strategy {
                            case .shallow:
                                property.name
                            case .deep:
                                if let type = property.type, type.hasSuffix("?") {
                                    "\(property.name)?.clone()"
                                } else {
                                    "\(property.name).clone()"
                                }
                            }
                        return "            \(property.name): \(expr)"
                    }.joined(separator: ",\n")
                    return """
                        func clone() -> \(typeName) {
                            \(typeName)(
                                \(propertyClones)
                            )
                        }
                        """
                }()
            } else {
                ""
            }

        let source = """
            extension \(typeName) {
                \(cloneMethod)
            }
            """
        let sourceFile = Parser.parse(source: source)
        guard let extensionDecl = sourceFile.statements.first?.item.as(ExtensionDeclSyntax.self)
        else {
            throw ClonableMacroError.invalidExtension
        }
        return extensionDecl
    }
}
public struct CloneMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        return []
    }
}

struct StoredProperty {
    let name: String
    let type: String?
    let strategy: CloneStrategy
}

enum CloneStrategy {
    case shallow
    case deep
}

enum ClonableMacroError: Error, CustomStringConvertible {
    case onlyApplicableToStruct
    case invalidExtension

    var description: String {
        switch self {
        case .onlyApplicableToStruct:
            return "@Clonable can only be applied to struct"
        case .invalidExtension:
            return "Cannot generate extension"
        }
    }
}

@main
struct SwiftClonablePlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        ClonableMacro.self
    ]
}
