//
//  LogicOperator.swift
//  alpaca-market-stream-server
//
//  Created by Peijun Zhao on 10/13/25.
//


import Foundation

enum LogicOperator: String, Codable, Sendable {
    case and = "AND"
    case or = "OR"
}