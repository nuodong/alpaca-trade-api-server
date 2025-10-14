//
//  AlpacaClient+TradingHelpers.swift
//  alpaca-swift
//
//  Created by Peijun Zhao on 9/25/25.
//


// MARK: - AlpacaClient+TradingHelpers.swift

import Foundation

public extension AlpacaClient {

    // MARK: - MARKET (qty) -----------------------------------------------------

    /// Place a MARKET **BUY** by quantity.
    /// - Parameters:
    ///   - symbol: JSON `symbol`
    ///   - qty: JSON `qty` (string), e.g. "1" or "0.5" if fractional enabled
    ///   - time_in_force: JSON `time_in_force` (default `.day`)
    ///   - extended_hours: JSON `extended_hours` (optional, market orders may allow it in certain sessions)
    ///   - client_order_id: JSON `client_order_id` for idempotency (optional)
    @discardableResult
    func marketBuy(
        symbol: String,
        qty: String,
        time_in_force: TimeInForce,
        client_order_id: String? = nil
    ) async throws -> AlpacaOrder {
        try await createOrder(.init(
            symbol: symbol,
            qty: qty,
            notional: nil,
            side: .buy,
            type: .market,
            time_in_force: time_in_force,
            limit_price: nil,
            stop_price: nil,
            trail_price: nil,
            trail_percent: nil,
            extended_hours: false, //extended_hour only applys to limit buy
            client_order_id: client_order_id,
            order_class: nil,
            take_profit: nil,
            stop_loss: nil,
            expire_at: nil
        ))
    }

    /// Place a MARKET **SELL** by quantity.
    @discardableResult
    func marketSell(
        symbol: String,
        qty: String,
        time_in_force: TimeInForce,
        client_order_id: String? = nil
    ) async throws -> AlpacaOrder {
        try await createOrder(.init(
            symbol: symbol,
            qty: qty,
            notional: nil,
            side: .sell,
            type: .market,
            time_in_force: time_in_force,
            limit_price: nil,
            stop_price: nil,
            trail_price: nil,
            trail_percent: nil,
            extended_hours: false, //extended_hour only applys to limit sell
            client_order_id: client_order_id,
            order_class: nil,
            take_profit: nil,
            stop_loss: nil,
            expire_at: nil
        ))
    }

    // MARK: - MARKET (notional/$ variable trading) -----------------------------
    // Note: Alpaca supports notional for MARKET orders. Provide USD as string.

    /// Place a MARKET **BUY** by notional (variable trading in USD).
    @discardableResult
    func marketBuyNotional(
        symbol: String,
        notional: String,
        time_in_force: TimeInForce,
        client_order_id: String? = nil
    ) async throws -> AlpacaOrder {
        try await createOrder(.init(
            symbol: symbol,
            qty: nil,
            notional: notional,
            side: .buy,
            type: .market,
            time_in_force: time_in_force,
            limit_price: nil,
            stop_price: nil,
            trail_price: nil,
            trail_percent: nil,
            extended_hours: false, //extended_hour only applys to limit buy
            client_order_id: client_order_id,
            order_class: nil,
            take_profit: nil,
            stop_loss: nil,
            expire_at: nil
        ))
    }

    /// Place a MARKET **SELL** by notional (variable trading in USD).
    @discardableResult
    func marketSellNotional(
        symbol: String,
        notional: String,
        time_in_force: TimeInForce,
        client_order_id: String? = nil
    ) async throws -> AlpacaOrder {
        try await createOrder(.init(
            symbol: symbol,
            qty: nil,
            notional: notional,
            side: .sell,
            type: .market,
            time_in_force: time_in_force,
            limit_price: nil,
            stop_price: nil,
            trail_price: nil,
            trail_percent: nil,
            extended_hours: false, //extended_hour only applys to limit sell
            client_order_id: client_order_id,
            order_class: nil,
            take_profit: nil,
            stop_loss: nil,
            expire_at: nil
        ))
    }

    // MARK: - LIMIT ------------------------------------------------------------

    /// LIMIT **BUY** (default GTC).
    @discardableResult
    func limitBuy(
        symbol: String,
        qty: String,
        limit_price: String,
        time_in_force: TimeInForce,
        extended_hours: Bool,
        client_order_id: String? = nil
    ) async throws -> AlpacaOrder {
        try await createOrder(.init(
            symbol: symbol,
            qty: qty,
            notional: nil,
            side: .buy,
            type: .limit,
            time_in_force: time_in_force,
            limit_price: limit_price,
            stop_price: nil,
            trail_price: nil,
            trail_percent: nil,
            extended_hours: extended_hours,
            client_order_id: client_order_id,
            order_class: nil,
            take_profit: nil,
            stop_loss: nil,
            expire_at: nil
        ))
    }

    /// LIMIT **SELL** (default GTC).
    @discardableResult
    func limitSell(
        symbol: String,
        qty: String,
        limit_price: String,
        time_in_force: TimeInForce,
        extended_hours: Bool,
        client_order_id: String? = nil
    ) async throws -> AlpacaOrder {
        try await createOrder(.init(
            symbol: symbol,
            qty: qty,
            notional: nil,
            side: .sell,
            type: .limit,
            time_in_force: time_in_force,
            limit_price: limit_price,
            stop_price: nil,
            trail_price: nil,
            trail_percent: nil,
            extended_hours: extended_hours,
            client_order_id: client_order_id,
            order_class: nil,
            take_profit: nil,
            stop_loss: nil,
            expire_at: nil
        ))
    }

    /// GTD LIMIT **BUY** with `expire_at` (RFC3339).
    @discardableResult
    func limitBuyGTD(
        symbol: String,
        qty: String,
        limit_price: String,
        expireAt: Date,
        extended_hours: Bool,
        client_order_id: String? = nil
    ) async throws -> AlpacaOrder {
        try await createOrder(.init(
            symbol: symbol,
            qty: qty,
            notional: nil,
            side: .buy,
            type: .limit,
            time_in_force: .gtd,
            limit_price: limit_price,
            stop_price: nil,
            trail_price: nil,
            trail_percent: nil,
            extended_hours: extended_hours,
            client_order_id: client_order_id,
            order_class: nil,
            take_profit: nil,
            stop_loss: nil,
            expire_at: rfc3339(expireAt)
        ))
    }

    /// GTD LIMIT **SELL** with `expire_at` (RFC3339).
    @discardableResult
    func limitSellGTD(
        symbol: String,
        qty: String,
        limit_price: String,
        expireAt: Date,
        extended_hours: Bool,
        client_order_id: String? = nil
    ) async throws -> AlpacaOrder {
        try await createOrder(.init(
            symbol: symbol,
            qty: qty,
            notional: nil,
            side: .sell,
            type: .limit,
            time_in_force: .gtd,
            limit_price: limit_price,
            stop_price: nil,
            trail_price: nil,
            trail_percent: nil,
            extended_hours: extended_hours,
            client_order_id: client_order_id,
            order_class: nil,
            take_profit: nil,
            stop_loss: nil,
            expire_at: rfc3339(expireAt)
        ))
    }

    // MARK: - STOP -------------------------------------------------------------

    /// STOP **BUY** (triggers a market buy when `stop_price` is reached).
    @discardableResult
    func stopBuy(
        symbol: String,
        qty: String,
        stop_price: String,
        time_in_force: TimeInForce,
        client_order_id: String? = nil
    ) async throws -> AlpacaOrder {
        try await createOrder(.init(
            symbol: symbol,
            qty: qty,
            notional: nil,
            side: .buy,
            type: .stop,
            time_in_force: time_in_force,
            limit_price: nil,
            stop_price: stop_price,
            trail_price: nil,
            trail_percent: nil,
            extended_hours: nil,
            client_order_id: client_order_id,
            order_class: nil,
            take_profit: nil,
            stop_loss: nil,
            expire_at: nil
        ))
    }

    /// STOP **SELL** (triggers a market sell when `stop_price` is reached).
    @discardableResult
    func stopSell(
        symbol: String,
        qty: String,
        stop_price: String,
        time_in_force: TimeInForce,
        client_order_id: String? = nil
    ) async throws -> AlpacaOrder {
        try await createOrder(.init(
            symbol: symbol,
            qty: qty,
            notional: nil,
            side: .sell,
            type: .stop,
            time_in_force: time_in_force,
            limit_price: nil,
            stop_price: stop_price,
            trail_price: nil,
            trail_percent: nil,
            extended_hours: nil,
            client_order_id: client_order_id,
            order_class: nil,
            take_profit: nil,
            stop_loss: nil,
            expire_at: nil
        ))
    }

    // MARK: - STOP-LIMIT -------------------------------------------------------

    /// STOP-LIMIT **BUY** (on stop trigger, place a limit buy at `limit_price`).
    @discardableResult
    func stopLimitBuy(
        symbol: String,
        qty: String,
        stop_price: String,
        limit_price: String,
        time_in_force: TimeInForce,
        client_order_id: String? = nil
    ) async throws -> AlpacaOrder {
        try await createOrder(.init(
            symbol: symbol,
            qty: qty,
            notional: nil,
            side: .buy,
            type: .stop_limit,
            time_in_force: time_in_force,
            limit_price: limit_price,
            stop_price: stop_price,
            trail_price: nil,
            trail_percent: nil,
            extended_hours: nil,
            client_order_id: client_order_id,
            order_class: nil,
            take_profit: nil,
            stop_loss: nil,
            expire_at: nil
        ))
    }

    /// STOP-LIMIT **SELL** (on stop trigger, place a limit sell at `limit_price`).
    @discardableResult
    func stopLimitSell(
        symbol: String,
        qty: String,
        stop_price: String,
        limit_price: String,
        time_in_force: TimeInForce,
        client_order_id: String? = nil
    ) async throws -> AlpacaOrder {
        try await createOrder(.init(
            symbol: symbol,
            qty: qty,
            notional: nil,
            side: .sell,
            type: .stop_limit,
            time_in_force: time_in_force,
            limit_price: limit_price,
            stop_price: stop_price,
            trail_price: nil,
            trail_percent: nil,
            extended_hours: nil,
            client_order_id: client_order_id,
            order_class: nil,
            take_profit: nil,
            stop_loss: nil,
            expire_at: nil
        ))
    }

    // MARK: - TRAILING STOP ----------------------------------------------------

    /// TRAILING STOP **SELL** trailing by **dollar** amount (`trail_price`).
    @discardableResult
    func trailingStopSellDollar(
        symbol: String,
        qty: String,
        trail_price: String,
        time_in_force: TimeInForce,
        client_order_id: String? = nil
    ) async throws -> AlpacaOrder {
        try await createOrder(.init(
            symbol: symbol,
            qty: qty,
            notional: nil,
            side: .sell,
            type: .trailing_stop,
            time_in_force: time_in_force,
            limit_price: nil,
            stop_price: nil,
            trail_price: trail_price,
            trail_percent: nil,
            extended_hours: nil,
            client_order_id: client_order_id,
            order_class: nil,
            take_profit: nil,
            stop_loss: nil,
            expire_at: nil
        ))
    }

    /// TRAILING STOP **SELL** trailing by **percent** (`trail_percent`).
    @discardableResult
    func trailingStopSellPercent(
        symbol: String,
        qty: String,
        trail_percent: String,
        time_in_force: TimeInForce,
        client_order_id: String? = nil
    ) async throws -> AlpacaOrder {
        try await createOrder(.init(
            symbol: symbol,
            qty: qty,
            notional: nil,
            side: .sell,
            type: .trailing_stop,
            time_in_force: time_in_force,
            limit_price: nil,
            stop_price: nil,
            trail_price: nil,
            trail_percent: trail_percent,
            extended_hours: nil,
            client_order_id: client_order_id,
            order_class: nil,
            take_profit: nil,
            stop_loss: nil,
            expire_at: nil
        ))
    }

    /// TRAILING STOP **BUY** trailing by **dollar** amount (useful when covering shorts).
    @discardableResult
    func trailingStopBuyDollar(
        symbol: String,
        qty: String,
        trail_price: String,
        time_in_force: TimeInForce,
        client_order_id: String? = nil
    ) async throws -> AlpacaOrder {
        try await createOrder(.init(
            symbol: symbol,
            qty: qty,
            notional: nil,
            side: .buy,
            type: .trailing_stop,
            time_in_force: time_in_force,
            limit_price: nil,
            stop_price: nil,
            trail_price: trail_price,
            trail_percent: nil,
            extended_hours: nil,
            client_order_id: client_order_id,
            order_class: nil,
            take_profit: nil,
            stop_loss: nil,
            expire_at: nil
        ))
    }

    /// TRAILING STOP **BUY** trailing by **percent** (useful when covering shorts).
    @discardableResult
    func trailingStopBuyPercent(
        symbol: String,
        qty: String,
        trail_percent: String,
        time_in_force: TimeInForce,
        client_order_id: String? = nil
    ) async throws -> AlpacaOrder {
        try await createOrder(.init(
            symbol: symbol,
            qty: qty,
            notional: nil,
            side: .buy,
            type: .trailing_stop,
            time_in_force: time_in_force,
            limit_price: nil,
            stop_price: nil,
            trail_price: nil,
            trail_percent: trail_percent,
            extended_hours: nil,
            client_order_id: client_order_id,
            order_class: nil,
            take_profit: nil,
            stop_loss: nil,
            expire_at: nil
        ))
    }

    // MARK: - BRACKET & OTO ----------------------------------------------------

    /// BRACKET **BUY** (parent market buy with child `take_profit` & `stop_loss`).
    /// - Note: Uses `order_class = .bracket`.
    @discardableResult
    func bracketBuyMarket(
        symbol: String,
        qty: String,
        take_profit_limit_price: String,
        stop_loss_stop_price: String,
        stop_loss_limit_price: String? = nil,
        client_order_id: String? = nil
    ) async throws -> AlpacaOrder {
        try await createOrder(.init(
            symbol: symbol,
            qty: qty,
            notional: nil,
            side: .buy,
            type: .market,
            time_in_force: .day,
            limit_price: nil,
            stop_price: nil,
            trail_price: nil,
            trail_percent: nil,
            extended_hours: nil,
            client_order_id: client_order_id,
            order_class: .bracket,
            take_profit: .init(limit_price: take_profit_limit_price),
            stop_loss: .init(stop_price: stop_loss_stop_price, limit_price: stop_loss_limit_price),
            expire_at: nil
        ))
    }

    /// OTO **BUY** (parent market buy, child `stop_loss` only).
    /// - Note: Uses `order_class = .oto`.
    @discardableResult
    func otoBuyMarket(
        symbol: String,
        qty: String,
        stop_loss_stop_price: String,
        stop_loss_limit_price: String? = nil,
        client_order_id: String? = nil
    ) async throws -> AlpacaOrder {
        try await createOrder(.init(
            symbol: symbol,
            qty: qty,
            notional: nil,
            side: .buy,
            type: .market,
            time_in_force: .day,
            limit_price: nil,
            stop_price: nil,
            trail_price: nil,
            trail_percent: nil,
            extended_hours: nil,
            client_order_id: client_order_id,
            order_class: .oto,
            take_profit: nil,
            stop_loss: .init(stop_price: stop_loss_stop_price, limit_price: stop_loss_limit_price),
            expire_at: nil
        ))
    }

    // MARK: - POSITION CLOSE HELPERS ------------------------------------------

    /// Close part of a position by **quantity** via DELETE /v2/positions/{symbol}.
    /// - Parameters map to query: `qty`, `time_in_force`, `limit_price`, `stop_price`, `trail_price`, `trail_percent`, `extended_hours`.
    @discardableResult
    func closePositionQty(
        symbol: String,
        qty: String,
        time_in_force: TimeInForce? = nil,
        limit_price: String? = nil,
        stop_price: String? = nil,
        trail_price: String? = nil,
        trail_percent: String? = nil,
        extended_hours: Bool? = nil
    ) async throws -> [AlpacaOrder] {
        try await closePosition(
            symbol: symbol,
            qty: qty,
            percentage: nil,
            time_in_force: time_in_force,
            limit_price: limit_price,
            stop_price: stop_price,
            trail_price: trail_price,
            trail_percent: trail_percent,
            extended_hours: extended_hours,
            side: nil
        )
    }

    /// Close part of a position by **percentage** via DELETE /v2/positions/{symbol}.
    /// - Parameter percentage: JSON `percentage` as string, e.g. "25" to close 25%.
    @discardableResult
    func closePositionPercentage(
        symbol: String,
        percentage: String,
        time_in_force: TimeInForce? = nil,
        limit_price: String? = nil,
        stop_price: String? = nil,
        trail_price: String? = nil,
        trail_percent: String? = nil,
        extended_hours: Bool? = nil
    ) async throws -> [AlpacaOrder] {
        try await closePosition(
            symbol: symbol,
            qty: nil,
            percentage: percentage,
            time_in_force: time_in_force,
            limit_price: limit_price,
            stop_price: stop_price,
            trail_price: trail_price,
            trail_percent: trail_percent,
            extended_hours: extended_hours,
            side: nil
        )
    }

    /// Close **all** positions (optionally cancel working orders first).
    @discardableResult
    func closeAllPositionsFast(cancel_orders: Bool = true, time_in_force: TimeInForce? = .ioc) async throws -> [CloseAllResult] {
        try await closeAllPositions(cancel_orders: cancel_orders, time_in_force: time_in_force)
    }
}

// MARK: - Private helper

private extension AlpacaClient {
    /// RFC3339 / ISO-8601 without fractional seconds (suitable for `expire_at`)
    func rfc3339(_ date: Date) -> String {
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime]
        return iso.string(from: date)
    }
}
