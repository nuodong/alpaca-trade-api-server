//
//  SubscriptionRequestMessage.swift
//  AlpacaMarketWebsocketClient
//
//  Created by Peijun Zhao on 10/8/25.
//
import Foundation

///Alpaca server will append these new values to existing ones
struct SubscriptionRequestMessage: Codable,Sendable {
    var action: String = "subscription"
    var trades: [String]? = []
    var quotes: [String]? = []
    var bars: [String]? = []
    
    init() {
        
    }
    init( trades: [String]?,quotes: [String]?,bars: [String]?) {
        self.trades = trades
        self.quotes = quotes
        self.bars = bars
    }
    
    func jsonString() async -> String {
        let data = (try? JSONEncoder().encode(self)) ?? Data()
        let jsonString = String(data: data, encoding: .utf8) ?? ""
        return jsonString
    }
}
