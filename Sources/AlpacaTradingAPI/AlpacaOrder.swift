//
//  AlpacaOrder.swift
//  alpaca-swift
//
//  Created by Peijun Zhao on 9/25/25.
//

import Foundation
/// Order object returned by Alpaca.
public struct AlpacaOrder: Codable, Hashable, Sendable, Identifiable {
    /// Unique order ID (UUID).
    public let id: String
    /// Client-supplied order ID if provided.
    public let client_order_id: String
    /// Symbol for the order.
    public let symbol: String
    /// Asset class.
    public let asset_class: String
    /// Notional amount if notional order was used.
    public let notional: String?
    /// Order side.
    public let side: OrderSide
    /// Order type.
    public let type: OrderType
    /// Time in force.
    public let time_in_force: TimeInForce
    /// Limit price if applicable.
    public let limit_price: String?
    /// Stop trigger price if applicable.
    public let stop_price: String?
    /// Quantity requested.
    public let qty: String?
    /// Filled quantity so far.
    public let filled_qty: String
    /// Filled average price (if any).
    public let filled_avg_price: String?
    /// Submitted timestamp.
    public let submitted_at: Date?
    /// Updated timestamp.
    public let updated_at: Date?
    /// Creation timestamp.
    public let created_at: Date?
    /// Expiration timestamp (for GTD).
    public let expires_at: Date?
    /// Current order status, e.g., "new", "partially_filled", "filled", "canceled", "replaced".
    public let status: String
    /// Extended hours flag.
    public let extended_hours: Bool
    /// Replacement of another order ID (if applicable).
    public let replaced_by: String?
    /// ID of the order this order replaced (if applicable).
    public let replaces: String?
    /// Stock lending-related flag for short sales (if present).
    public let short_id: String?
    /// Order class (simple/bracket/oco/oto).
    public let order_class: AlpacaOrderClass?
    /// Trail price used for trailing stop orders.
    public let trail_price: String?
    /// Trail percent used for trailing stop orders.
    public let trail_percent: String?
    /// Current trailing stop offset in dollars.
    public let hwm: String?
    /// Legs for multi-leg orders (e.g., bracket). Present when `order_class` != simple.
    public let legs: [AlpacaOrder]?
}
