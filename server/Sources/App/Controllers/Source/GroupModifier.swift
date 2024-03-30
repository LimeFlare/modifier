//
//  GroupModifier.swift
//  SSTest
//
//  Created by Kael Yang on 26/8/2020.
//  Copyright © 2020 Kael Yang. All rights reserved.
//

import Foundation

// MARK: - Variable declaractions & Convenience mutating function
extension Surge {
    struct GroupModifier {
        enum ModificationType {
            case replace
            case modify
        }

        let groupName: String

        var name: String?
        var modificationType: ModificationType = .replace {
            didSet {
                if oldValue != modificationType {
                    self.cleanContentsForTypeChanging()
                }
            }
        }

        var isBasedOnResources: Bool = false
        var requiredModifierNames: [String] = []

        var insertedModifiers: [Modifier] = []
        var appendedModifiers: [Modifier] = []
        var updators: [Updator] = []

        var resources: Set<URL> = []

        private mutating func addResourceIfNeeded(for modifier: Modifier) {
            if case .resource(let url) = modifier {
                resources.insert(url)
            }
        }

        mutating func add(insertedModifier modifierr: Modifier) {
            addResourceIfNeeded(for: modifierr)
            insertedModifiers.append(modifierr)
        }

        mutating func add(appendedModifier modifierr: Modifier) {
            addResourceIfNeeded(for: modifierr)
            appendedModifiers.append(modifierr)
        }

        mutating func add(updator: Updator) {
            updators.append(updator)
        }

        private mutating func cleanContentsForTypeChanging() {
            self.insertedModifiers = []
            self.appendedModifiers = []
            self.updators = []
            self.resources = []
        }
    }
}

// MARK: - Extractor
extension Surge.GroupModifier {
    typealias ExtractResult = (groupModifiers: [Self], resources: Set<URL>)
    private static let decoratorHelperRegex = try! NSRegularExpression(pattern: #"^#!([^\s\r]+)\s*"#, options: [.anchorsMatchLines])
    static func extract(from string: String) -> ExtractResult {
        let splittedLines = string.components(separatedBy: .newlines)

        var 