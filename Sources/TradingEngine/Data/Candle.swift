//
//  Candle.swift
//  alpaca-market-stream-server
//
//  Created by Peijun Zhao on 10/12/25.
//

import Foundation

public struct Candle {
    let open: Double
    let high: Double
    let low: Double
    let close: Double
    let volume: Double
    let timestamp: Date
}
