//
//  SubscriptionRequestMessage.swift
//  AlpacaMarketWebsocketClient
//
//  Created by Peijun Zhao on 10/8/25.
//
import Foundation

 public struct SubscriptionRequestMessage: Codable,Sendable {
    public var action: String = "subscription"
    public var trades: [String]? = []
    public var quotes: [String]? = []
    public var bars: [String]? = []
    
    public init() {
        
    }
    public init( trades: [String]?,quotes: [String]?,bars: [String]?) {
        self.action = "subscription"
        self.trades = trades
        self.quotes = quotes
        self.bars = bars
    }
    
    public func jsonString() async -> String {
        let data = (try? JSONEncoder().encode(self)) ?? Data()
        let jsonString = String(data: data, encoding: .utf8) ?? ""
        return jsonString
    }
}
