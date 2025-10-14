//
//  Condition.swift
//  alpaca-market-stream-server
//
//  Created by Peijun Zhao on 10/13/25.
//


import Foundation

///indirect tells Swift that the enum’s cases may contain recursive references — i.e., an enum case can store another instance of the same enum inside itself.
indirect enum Condition: Codable, Sendable {
    case comparison(left: String, op: CompareOperator, right: String)
    case logic(op: LogicOperator, left: Condition, right: Condition)

    // MARK: Codable Implementation
    private enum CodingKeys: String, CodingKey { case type, left, right, op }
    private enum ConditionType: String, Codable { case comparison, logic }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let type = try c.decode(ConditionType.self, forKey: .type)
        switch type {
        case .comparison:
            let left = try c.decode(String.self, forKey: .left)
            let op = try c.decode(CompareOperator.self, forKey: .op)
            let right = try c.decode(String.self, forKey: .right)
            self = .comparison(left: left, op: op, right: right)
        case .logic:
            let op = try c.decode(LogicOperator.self, forKey: .op)
            let left = try c.decode(Condition.self, forKey: .left)
            let right = try c.decode(Condition.self, forKey: .right)
            self = .logic(op: op, left: left, right: right)
        }
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .comparison(let left, let op, let right):
            try c.encode(ConditionType.comparison, forKey: .type)
            try c.encode(left, forKey: .left)
            try c.encode(op, forKey: .op)
            try c.encode(right, forKey: .right)
        case .logic(let op, let left, let right):
            try c.encode(ConditionType.logic, forKey: .type)
            try c.encode(op, forKey: .op)
            try c.encode(left, forKey: .left)
            try c.encode(right, forKey: .right)
        }
    }
}


// MARK: - String Conversion (Expression Reconstruction)

extension Condition {
    func toExpressionString() -> String {
        switch self {
        case .comparison(let left, let op, let right):
            return "\(left) \(op.rawValue) \(right)"
        case .logic(let op, let left, let right):
            let leftStr = left.needsParentheses(for: op) ? "(\(left.toExpressionString()))" : left.toExpressionString()
            let rightStr = right.needsParentheses(for: op) ? "(\(right.toExpressionString()))" : right.toExpressionString()
            return "\(leftStr) \(op.rawValue) \(rightStr)"
        }
    }

    private func needsParentheses(for parentOp: LogicOperator) -> Bool {
        // Add parentheses when nested AND inside OR to preserve precedence
        switch (self, parentOp) {
        case (.logic(let op, _, _), .or) where op == .and:
            return true
        default:
            return false
        }
    }
}
