//
//  CreateOrderRequest.swift
//  alpaca-swift
//
//  Created by Peijun Zhao on 9/25/25.
//

import Foundation
/// Request body to create an order.
/// Use **either** `qty` **or** `notional`.
public struct CreateOrderRequest: Codable, Hashable, Sendable {
    /// Symbol to trade, e.g., "AAPL".
    public let symbol: String
    /// Quantity to trade as a string (supports fractional if enabled).
    public let qty: String?
    /// Notional amount in USD as a string (mutually exclusive with qty).
    public let notional: String?
    /// Side of the order.
    public let side: OrderSide
    /// Order type.
    public let type: OrderType
    /// Time in force policy.
    public let time_in_force: TimeInForce
    /// Limit price for limit or stop-limit orders.
    public let limit_price: String?
    /// Stop trigger price for stop or stop-limit orders.
    public let stop_price: String?
    /// Trailing dollar amount for trailing stop.
    public let trail_price: String?
    /// Trailing percent for trailing stop (as string percentage).
    public let trail_percent: String?
    /// Extended hours flag for eligible orders.
    public let extended_hours: Bool?
    /// Optional client-supplied order ID for idempotency.
    public let client_order_id: String?
    /// Advanced order class (e.g., bracket).
    public let order_class: AlpacaOrderClass?
    /// Take-profit leg definition (for bracket or OTO).
    public let take_profit: TakeProfit?
    /// Stop-loss leg definition (for bracket or OTO).
    public let stop_loss: StopLoss?
    /// Expiration timestamp for `gtd` orders (RFC3339/ISO8601).
    public let expire_at: String?

    public init(
        symbol: String,
        qty: String? = nil,
        notional: String? = nil,
        side: OrderSide,
        type: OrderType,
        time_in_force: TimeInForce,
        limit_price: String? = nil,
        stop_price: String? = nil,
        trail_price: String? = nil,
        trail_percent: String? = nil,
        extended_hours: Bool? = nil,
        client_order_id: String? = nil,
        order_class: AlpacaOrderClass? = nil,
        take_profit: TakeProfit? = nil,
        stop_loss: StopLoss? = nil,
        expire_at: String? = nil
    ) {
        self.symbol = symbol
        self.qty = qty
        self.notional = notional
        self.side = side
        self.type = type
        self.time_in_force = time_in_force
        self.limit_price = limit_price
        self.stop_price = stop_price
        self.trail_price = trail_price
        self.trail_percent = trail_percent
        self.extended_hours = extended_hours
        self.client_order_id = client_order_id
        self.order_class = order_class
        self.take_profit = take_profit
        self.stop_loss = stop_loss
        self.expire_at = expire_at
    }
}
