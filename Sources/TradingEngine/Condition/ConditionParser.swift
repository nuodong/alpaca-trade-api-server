//
//  ConditionEvaluator.swift
//  Created for stock indicator condition parsing & evaluation
//

import Foundation

struct ConditionParser {
    private var tokens: [String]
    private var index = 0

    init(input: String) {
        let normalized = input
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "\r", with: " ")
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .replacingOccurrences(of: "(", with: " ( ")
            .replacingOccurrences(of: ")", with: " ) ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        tokens = normalized.components(separatedBy: " ").filter { !$0.isEmpty }
    }

    mutating func parse() throws -> Condition {
        return try parseOrExpression()
    }

    // OR is lowest precedence
    private mutating func parseOrExpression() throws -> Condition {
        var left = try parseAndExpression()
        while match("OR") {
            let right = try parseAndExpression()
            left = .logic(op: .or, left: left, right: right)
        }
        return left
    }

    // AND has higher precedence
    private mutating func parseAndExpression() throws -> Condition {
        var left = try parsePrimary()
        while match("AND") {
            let right = try parsePrimary()
            left = .logic(op: .and, left: left, right: right)
        }
        return left
    }

    private mutating func parsePrimary() throws -> Condition {
        if match("(") {
            let expr = try parseOrExpression()
            _ = expect(")")
            return expr
        } else {
            return try parseComparison()
        }
    }

    private mutating func parseComparison() throws -> Condition {
        guard index + 2 < tokens.count else {
            throw NSError(domain: "ConditionParser", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "Incomplete comparison"])
        }
        let left = tokens[index]; index += 1
        let opToken = tokens[index]; index += 1
        let right = tokens[index]; index += 1
        guard let op = CompareOperator(rawValue: opToken) else {
            throw NSError(domain: "ConditionParser", code: 2,
                          userInfo: [NSLocalizedDescriptionKey: "Invalid operator: \(opToken)"])
        }
        return .comparison(left: left, op: op, right: right)
    }

    // Helpers
    private mutating func match(_ word: String) -> Bool {
        if index < tokens.count && tokens[index].uppercased() == word.uppercased() {
            index += 1
            return true
        }
        return false
    }

    private mutating func expect(_ word: String) -> Bool {
        guard index < tokens.count else { return false }
        if tokens[index] == word {
            index += 1
            return true
        }
        return false
    }
}


extension ConditionParser {
    // MARK: - Example Usage
    func testConditionParser() {
        let input = """
        (PRICE > 130.0 AND PRICE > 140.0)
        OR (PRICE < 200 OR PRICE < 200 AND PRICE > 200)
        """

        do {
            let model = try ConditionModel(rawExpression: input)
            let evaluator = ConditionEvaluator(stockData: ["PRICE": 100])
            let result = evaluator.evaluate(model.rootCondition)

            print("Expression: \(input)")
            print("Reconstructed: \(model.toRawExpression())")
            print("Evaluation result: \(result)\n")

            // Encode to JSON
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let json = try encoder.encode(model)
            print("Encoded JSON:\n" + (String(data: json, encoding: .utf8) ?? ""))

            // Decode back
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(ConditionModel.self, from: json)
            print("\nDecoded expression:")
            print(decoded.toRawExpression())
            print("Decoded evaluation: \(ConditionEvaluator(stockData: ["PRICE": 100]).evaluate(decoded.rootCondition))")

        } catch {
            print("Error: \(error)")
        }

    }

}

