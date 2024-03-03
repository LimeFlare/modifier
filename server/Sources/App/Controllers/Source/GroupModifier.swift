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

        