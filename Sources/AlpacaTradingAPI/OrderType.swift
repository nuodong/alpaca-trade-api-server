//
//  OrderType.swift
//  alpaca-swift
//
//  Created by Peijun Zhao on 9/25/25.
//

import Foundation
public enum OrderType: String, Codable, Hashable, Sendable {
    /// Market order.
    case market
    /// Limit order.
    case limit
    /// Stop order.
    case stop
    /// Stop-limit order.
    case stop_limit
    /// Trailing stop order.
    case trailing_stop
}
