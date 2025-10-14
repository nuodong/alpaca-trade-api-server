//
//  AlpacaClock.swift
//  alpaca-swift
//
//  Created by Peijun Zhao on 9/25/25.
//

import Foundation
// MARK: AlpacaClock

/// Market clock and session status.
public struct AlpacaClock: Codable, Hashable, Sendable {
    /// True if the market is currently open.
    public let is_open: Bool
    /// Current timestamp (exchange time).
    public let timestamp: Date
    /// Next market open time.
    public let next_open: Date
    /// Next market close time.
    public let next_close: Date
}
