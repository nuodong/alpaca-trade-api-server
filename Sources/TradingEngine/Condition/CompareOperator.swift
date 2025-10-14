//
//  CompareOperator.swift
//  alpaca-market-stream-server
//
//  Created by Peijun Zhao on 10/13/25.
//


import Foundation

enum CompareOperator: String, Codable, Sendable {
    case greater = ">"
    case less = "<"
    case greaterEqual = ">="
    case lessEqual = "<="
    case equal = "="
    case equalequal = "=="
    case notEqual = "!="
}
