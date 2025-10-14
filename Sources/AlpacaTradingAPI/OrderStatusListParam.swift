//
//  OrderStatusListParam.swift
//  alpaca-swift
//
//  Created by Peijun Zhao on 9/25/25.
//

import Foundation
public enum OrderStatusListParam: String, Codable, Hashable, Sendable {
    /// Open orders only.
    case open
    /// Closed orders only.
    case closed
    /// All orders.
    case all
}
