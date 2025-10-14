//
//  OrderSide.swift
//  alpaca-swift
//
//  Created by Peijun Zhao on 9/25/25.
//

import Foundation
public enum OrderSide: String, Codable, Hashable, Sendable {
    /// Buy order.
    case buy
    /// Sell order.
    case sell
}
