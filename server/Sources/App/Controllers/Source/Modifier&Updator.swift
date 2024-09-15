
//
//  Modifier&Updator.swift
//  SSTest
//
//  Created by Kael Yang on 26/8/2020.
//  Copyright © 2020 Kael Yang. All rights reserved.
//

import Foundation

private typealias SplittedValue = (valueArray: [String], functionIndics: [Int])
private func split(valueString: String) -> SplittedValue {
    var valueArray: [String] = []
    var functionIndics: [Int] = []

    var parenthesesLevel = 0
    var quoteSet: Set<Character> = []
    var lastIndex = valueString.startIndex

    func insertResultToValueArray(withCurrentIndex currentIndex: String.Index) {
        let result = String(valueString[lastIndex ..< currentIndex]).trimmingCharacters(in: .whitespaces)
        valueArray.append(result)
        if result.starts(with: "$") {
            functionIndics.append(valueArray.count - 1)
        }
    }

    valueString.indices.forEach { stringIndex in
        let char = valueString[stringIndex]
        switch char {
        case ",":
            guard parenthesesLevel <= 0 && quoteSet.isEmpty else { return }

            insertResultToValueArray(withCurrentIndex: stringIndex)
            lastIndex = valueString.index(after: stringIndex)
        case "\'", "\"":