//
//  TakeProfit.swift
//  alpaca-swift
//
//  Created by Peijun Zhao on 9/25/25.
//

import Foundation
/// Child leg for take-profit in bracket/OTO/… classes.
public struct TakeProfit: Codable, Hashable, Sendable {
    /// Limit price for take-profit leg.
    public let limit_price: String
}
