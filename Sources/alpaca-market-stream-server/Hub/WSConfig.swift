//
//  WSConfig.swift
//  AlpacaMarketWebsocketClient
//
//  Created by Peijun Zhao on 10/8/25.
//


// ===============================
// Config
// ===============================

struct WSConfig: Sendable {
    let queueCapacity: Int = 32                  // per-client buffer size
    let writeTimeout: Duration = .seconds(2)     // per-message write timeout
    let disconnectOnOverflow: Bool = true       // true: kick laggards if buffer overflows
}
