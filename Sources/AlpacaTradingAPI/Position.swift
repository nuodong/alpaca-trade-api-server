//
//  Position.swift
//  alpaca-swift
//
//  Created by Peijun Zhao on 9/25/25.
//

import Foundation
/// Open position information.
public struct Position: Codable, Hashable, Sendable {
    /// Symbol for the position.
    public let symbol: String
    /// Asset ID (UUID).
    public let asset_id: String
    /// Asset class.
    public let asset_class: String
    /// Average entry price.
    public let avg_entry_price: String
    /// Quantity currently held.
    public let qty: String
    /// Side of position ("long" or "short").
    public let side: String
    /// Market value in USD.
    public let market_value: String
    /// Cost basis in USD.
    public let cost_basis: String
    /// Unrealized P/L in USD.
    public let unrealized_pl: String
    /// Unrealized P/L percent.
    public let unrealized_plpc: String
    /// Unrealized intraday P/L in USD.
    public let unrealized_intraday_pl: String
    /// Unrealized intraday P/L percent.
    public let unrealized_intraday_plpc: String
    /// Current price.
    public let current_price: String
    /// Last trade price at previous session close.
    public let lastday_price: String
    /// Change since last close in USD.
    public let change_today: String
}
