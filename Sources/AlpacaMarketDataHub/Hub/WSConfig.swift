//
//  WSConfig.swift
//  AlpacaMarketWebsocketClient
//
//  Created by Peijun Zhao on 10/8/25.
//


// ===============================
// Config
// ===============================

public struct WSConfig: Sendable {
    public let queueCapacity: Int = 100                  // per-client buffer size
    public let writeTimeout: Duration = .seconds(2)     // per-message write timeout
    public let disconnectOnOverflow: Bool = true       // true: kick laggards if buffer overflows
    
    public init () {}
}
