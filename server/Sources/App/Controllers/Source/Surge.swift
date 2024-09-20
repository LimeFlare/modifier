
//
//  Surge.swift
//  SSTest
//
//  Created by Kael Yang on 26/8/2020.
//  Copyright © 2020 Kael Yang. All rights reserved.
//

import Foundation

public enum Surge { }

extension Surge {
    static func generate(with groupModifiers: [GroupModifier], resources: Surge.GroupModifier.Resources, skipNormalProxy: Bool) -> String {

        // 1. flat all resource modifiers.
        let flattedGroupModifiers: [GroupModifier] = groupModifiers.map { groupModifier in
            let flatResult = groupModifier.flat(withResources: resources, skipNormalProxy: skipNormalProxy)

            switch flatResult {
            case .success(let flattedModifier):
                return flattedModifier
            case .failure(let resourceError):
                var fallbackModifier = GroupModifier(groupName: groupModifier.groupName)
                fallbackModifier.modificationType = .modify
                fallbackModifier.add(insertedModifier: GroupModifier.Modifier.plain("# Group \(groupModifier.name ?? groupModifier.groupName) is removed since resource \(resourceError.url.absoluteString) is not downloaded."))
                return fallbackModifier
            }
        }

        // 2. filter optional modifiers. (required modifier not found)
        let filtedGroupModifiers = flattedGroupModifiers.filter { modifier -> Bool in
            let requiredModifiers = modifier.requiredModifierNames
            return requiredModifiers.allSatisfy { name -> Bool in
                flattedGroupModifiers.contains(where: { $0.name == name })
            }
        }

        typealias GroupName = String
