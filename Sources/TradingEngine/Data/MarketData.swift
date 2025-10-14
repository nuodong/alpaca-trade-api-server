//
//  MarketData.swift
//  alpaca-market-stream-server
//
//  Created by Peijun Zhao on 10/13/25.
//
import Foundation

public struct MarketData: Codable, Sendable, Identifiable {
    public var id: String
    public var datems: Int //milliseconds of this data generated
    public var data: [MarketDataIndicator: String]
}
