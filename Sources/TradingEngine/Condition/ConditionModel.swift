//
//  ConditionModel.swift
//  alpaca-market-stream-server
//
//  Created by Peijun Zhao on 10/13/25.
//

import Foundation

/// Codable Wrapper for Parser Input and Model
struct ConditionModel: Codable, Sendable {
    var rawExpression: String
    var rootCondition: Condition

    init(rawExpression: String) throws {
        self.rawExpression = rawExpression
        var parser = ConditionParser(input: rawExpression)
        self.rootCondition = try parser.parse()
    }

    func toRawExpression() -> String {
        return rootCondition.toExpressionString()
    }
}

