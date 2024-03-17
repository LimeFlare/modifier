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
       