//
//  StopLoss.swift
//  alpaca-swift
//
//  Created by Peijun Zhao on 9/25/25.
//

import Foundation
/// Child leg for stop-loss in bracket/OTO/… classes.
public struct StopLoss: Codable, Hashable, Sendable {
    /// Stop trigger price for stop-loss leg.
    public let stop_price: String?
    /// Limit price for stop-limit style stop-loss.
    public let limit_price: String?
}
