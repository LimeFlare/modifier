
//
//  FunctionHandler.swift
//  SSTest
//
//  Created by Kael Yang on 27/8/2020.
//  Copyright © 2020 Kael Yang. All rights reserved.
//

import Foundation

fileprivate protocol FunctionType {
    static var matchingRegex: NSRegularExpression { get }

    static func handle(function: NSString, matchingResult: NSTextCheckingResult, referenceModifiers: [Surge.GroupModifier]) -> String
}

extension Surge.GroupModifier.Modifier.KeyValue {
    private static let allFunctionTypes: [FunctionType.Type] = [GroupFilterFunction.self]

    func handleFunction(withReferenceModifiers groupModifiers: [Surge.GroupModifier]) -> Self {
        var copy = self

        self.functionIndics.forEach { functionIndex in
            let functionString = self.values[functionIndex]

            let nsFunctionString = NSString(string: functionString)

            for functionType in Self.allFunctionTypes {
                guard let matched = functionType.matchingRegex.firstMatch(in: functionString, options: [], range: NSRange(location: 0, length: nsFunctionString.length)) else {
                    continue
                }
                let functionResult = functionType.handle(function: nsFunctionString, matchingResult: matched, referenceModifiers: groupModifiers)
                copy.values[functionIndex] = functionResult
                break
            }
        }

        return copy
    }
}
// MARK: - Group key filter function
// Syntax: $group('modifierName', operator, 'operand')
fileprivate enum GroupFilterFunction: FunctionType {
    private enum Operator {
        case contains
        case matches
        case prefix
        case suffix

        init?(rawValue: String) {
            switch rawValue {
            case "contains", "contain": self = .contains
            case "matches", "match": self = .matches
            case "prefix": self = .prefix
            case "suffix": self = .suffix
            default: return nil