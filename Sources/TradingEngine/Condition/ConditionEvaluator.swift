//
//  ConditionEvaluator.swift
//  alpaca-market-stream-server
//
//  Created by Peijun Zhao on 10/13/25.
//


import Foundation

struct ConditionEvaluator {
    let stockData: [String: Double]
    

    init(stockData: [String: Double] ) {
        self.stockData = stockData
    }

    func evaluate(_ condition: Condition) -> Bool {
        let epsilon: Double = 1e-7// floating-point tolerance
        switch condition {
        case .comparison(let left, let op, let right):
            guard let leftValue = stockData[left.uppercased()] else { return false }
            let rightValue = parseRightValue(right, base: leftValue)
            switch op {
            case .greater: return leftValue > rightValue + epsilon
            case .less: return leftValue < rightValue - epsilon
            case .greaterEqual: return leftValue >= rightValue - epsilon
            case .lessEqual: return leftValue <= rightValue + epsilon
            case .equal, .equalequal: return abs(leftValue - rightValue) < epsilon
            case .notEqual: return abs(leftValue - rightValue) >= epsilon
            }
        case .logic(let op, let left, let right):
            switch op {
            case .and: return evaluate(left) && evaluate(right)
            case .or:  return evaluate(left) || evaluate(right)
            }
        }
    }

    private func parseRightValue(_ text: String, base: Double) -> Double {
        if text.hasSuffix("%") {
            let numStr = text.dropLast()
            if let percent = Double(numStr) {
                return base * (1 + percent / 100.0)
            }
        }
        return Double(text) ?? 0.0
    }
}
