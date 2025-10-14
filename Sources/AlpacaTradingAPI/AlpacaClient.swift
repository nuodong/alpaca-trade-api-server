//
//  AlpacaClient.swift
//  alpaca-swift
//
//  Created by Peijun Zhao on 9/25/25.
//

// MARK: - Client
//  Usage:
//  let client = AlpacaClient(
//      keyId: "<APCA-API-KEY-ID>",
//      secretKey: "<APCA-API-SECRET-KEY>",
//      environment: .paper // or .live
//  )
//
//  let account = try await client.getAccount()
//  let order = try await client.createOrder(
//      .init(symbol: "AAPL", qty: "1", side: .buy, type: .market, time_in_force: .day)
//  )
//

import Foundation
import Logging

public final class AlpacaClient {
    public enum Environment: String {
        /// Paper trading base URL
        case paper = "https://paper-api.alpaca.markets"
        /// Live trading base URL
        case live  = "https://api.alpaca.markets"
    }

    private let keyId: String
    private let secretKey: String
    private let baseURL: URL
    private let session: URLSession
    private let jsonDecoder: JSONDecoder
    private let jsonEncoder: JSONEncoder
    private let logger: Logger = Logger(label: "alpacaapiclient")

    public init(
        keyId: String,
        secretKey: String,
        environment: Environment,
    ) {
        self.keyId = keyId
        self.secretKey = secretKey
        self.baseURL = URL(string: environment.rawValue)!
        
        // Create a custom configuration
        let config = URLSessionConfiguration.default
        // Set this to a higher number (default is usually 4–6)
        config.httpMaximumConnectionsPerHost = 50

        // Optionally adjust other limits
        config.timeoutIntervalForRequest = 30 // If no data for 30s, fail

        // Create the session with your config
        self.session = URLSession(configuration: config)

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        decoder.dateDecodingStrategy = .iso8601
        self.jsonDecoder = decoder

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .useDefaultKeys
        encoder.dateEncodingStrategy = .iso8601
        self.jsonEncoder = encoder
    }

    // MARK: - Low-level request helper

    private func request<T: Decodable>(
        _ method: String,
        path: String,
        query: [String: String?] = [:],
        body: Encodable? = nil
    ) async throws -> T {
        var url = baseURL.appendingPathComponent(path)
        if !query.isEmpty {
            var comps = URLComponents(url: url, resolvingAgainstBaseURL: false)!
            comps.queryItems = query.compactMap { key, value in
                guard let value else { return nil }
                return URLQueryItem(name: key, value: value)
            }
            url = comps.url!
        }

        var req = URLRequest(url: url)
        req.httpMethod = method
        req.setValue(keyId, forHTTPHeaderField: "APCA-API-KEY-ID")
        req.setValue(secretKey, forHTTPHeaderField: "APCA-API-SECRET-KEY")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        if let body {
            req.httpBody = try jsonEncoder.encode(AnyEncodable(body))
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        //only decode string when log level is trace to avoid unnecessary encoding/decoding
        if logger.logLevel == .trace {
            let bodyString = String(data: req.httpBody ?? Data(), encoding: .utf8) ?? ""
            let pretty = bodyString.prettyPrintedJsonString()
            logger.trace("* Sending Api Request [\(req.httpMethod ?? "")]: \(url)\n\(pretty)\n")
        }
        
        
        let (data, resp) = try await session.data(for: req)
        guard let http = resp as? HTTPURLResponse else {
            throw AlpacaError.network(description: "Invalid response")
        }
        
        //only decode string when log level is trace to avoid unnecessary encoding/decoding
        if logger.logLevel == .trace {
            let responseBody = String(data: data, encoding: .utf8) ?? ""
            let pretty = responseBody.prettyPrintedJsonString()
            logger.trace("* Received Api Response for [\(req.httpMethod ?? "")] (\(url))\n\(pretty)\n")
        }
        
        if (200..<300).contains(http.statusCode) {
            if T.self == Empty.self {
                // For endpoints returning empty body
                return Empty() as! T
            }
            return try jsonDecoder.decode(T.self, from: data)
        } else {
            // Try to decode API error shape; otherwise bubble up raw text
            if let apiErr = try? jsonDecoder.decode(APIError.self, from: data) {
                throw AlpacaError.api(apiErr, status: http.statusCode)
            } else if let txt = String(data: data, encoding: .utf8) {
                throw AlpacaError.http(status: http.statusCode, body: txt)
            } else {
                throw AlpacaError.http(status: http.statusCode, body: "<binary>")
            }
        }
    }

    // Convenience for requests without typed body/response
    private struct Empty: Codable {}

    // MARK: - Accounts

    /// GET /v2/account
    public func getAccount() async throws -> AlpacaAccount {
        try await request("GET", path: "/v2/account")
    }

    // MARK: - Clock

    /// GET /v2/clock
    public func getClock() async throws -> AlpacaClock {
        try await request("GET", path: "/v2/clock")
    }

    // MARK: - Assets (lookup, useful when placing orders)

    /// GET /v2/assets
    public func listAssets(
        status: AlpacaAssetStatus? = nil,
        asset_class: String? = nil,
        exchange: String? = nil,
        attributes: [String]? = nil
    ) async throws -> [AlpacaAsset] {
        let query: [String: String?] = [
            "status": status?.rawValue,
            "asset_class": asset_class,
            "exchange": exchange,
            "attributes": attributes?.joined(separator: ",")
        ]
        return try await request("GET", path: "/v2/assets", query: query)
    }

    /// GET /v2/assets/{symbol_or_asset_id}
    public func getAsset(_ symbol_or_asset_id: String) async throws -> AlpacaAsset {
        try await request("GET", path: "/v2/assets/\(symbol_or_asset_id)")
    }

    // MARK: - Orders

    /// POST /v2/orders
    public func createOrder(_ order: CreateOrderRequest) async throws -> AlpacaOrder {
        try await request("POST", path: "/v2/orders", body: order)
    }

    /// GET /v2/orders
    public func listOrders(
        status: OrderStatusListParam? = nil,
        limit: Int? = nil,
        after: Date? = nil,
        until: Date? = nil,
        direction: ListDirection? = nil,
        nested: Bool? = nil,
        symbols: [String]? = nil,
        side: OrderSide? = nil
    ) async throws -> [AlpacaOrder] {
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let query: [String: String?] = [
            "status": status?.rawValue,
            "limit": limit.map(String.init),
            "after": after.map { iso.string(from: $0) },
            "until": until.map { iso.string(from: $0) },
            "direction": direction?.rawValue,
            "nested": nested.map { $0 ? "true" : "false" },
            "symbols": symbols?.joined(separator: ","),
            "side": side?.rawValue
        ]
        return try await request("GET", path: "/v2/orders", query: query)
    }

    /// GET /v2/orders/{order_id}
    public func getOrder(order_id: String) async throws -> AlpacaOrder {
        try await request("GET", path: "/v2/orders/\(order_id)")
    }

    /// GET /v2/orders:by_client_order_id
    public func getOrderByClientId(client_order_id: String) async throws -> AlpacaOrder {
        try await request("GET", path: "/v2/orders:by_client_order_id", query: ["client_order_id": client_order_id])
    }

    /// DELETE /v2/orders/{order_id}
    public func cancelOrder(order_id: String) async throws {
        
        _ = try await request( "DELETE", path: "/v2/orders/\(order_id)") as Empty
    }
    
    /// DELETE /v2/orders
    public func cancelAllOrders() async throws -> CancelAllResponse {
        try await request("DELETE", path: "/v2/orders")
    }

    // MARK: - Positions

    /// GET /v2/positions
    public func listPositions() async throws -> [Position] {
        try await request("GET", path: "/v2/positions")
    }

    /// GET /v2/positions/{symbol}
    public func getPosition(symbol: String) async throws -> Position {
        try await request("GET", path: "/v2/positions/\(symbol)")
    }

    /// DELETE /v2/positions/{symbol}
    public func closePosition(
        symbol: String,
        qty: String? = nil,
        percentage: String? = nil,
        time_in_force: TimeInForce? = nil,
        limit_price: String? = nil,
        stop_price: String? = nil,
        trail_price: String? = nil,
        trail_percent: String? = nil,
        extended_hours: Bool? = nil,
        side: ClosePositionSide? = nil
    ) async throws -> [AlpacaOrder] {
        let query: [String: String?] = [
            "qty": qty,
            "percentage": percentage,
            "time_in_force": time_in_force?.rawValue,
            "limit_price": limit_price,
            "stop_price": stop_price,
            "trail_price": trail_price,
            "trail_percent": trail_percent,
            "extended_hours": extended_hours.map { $0 ? "true" : "false" },
            "side": side?.rawValue
        ]
        return try await request("DELETE", path: "/v2/positions/\(symbol)", query: query)
    }

    /// DELETE /v2/positions
    public func closeAllPositions(
        cancel_orders: Bool? = nil,
        time_in_force: TimeInForce? = nil
    ) async throws -> [CloseAllResult] {
        let query: [String: String?] = [
            "cancel_orders": cancel_orders.map { $0 ? "true" : "false" },
            "time_in_force": time_in_force?.rawValue
        ]
        return try await request("DELETE", path: "/v2/positions", query: query)
    }
}
