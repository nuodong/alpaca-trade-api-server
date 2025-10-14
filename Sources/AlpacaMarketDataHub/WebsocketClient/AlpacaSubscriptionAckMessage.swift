//
//  AlpacaSubscriptionAckMessage.swift
//  alpaca-market-stream-server
//
//  Created by Peijun Zhao on 10/10/25.
//


import Foundation

struct AlpacaSubscriptionAckMessage: AlpacaMarketDataMessage {
    let T: String // always "subscription"
    let trades: [String]?
    let quotes: [String]?
    let bars: [String]?
    
    init( trades: [String]?,quotes: [String]?,bars: [String]?) {
        self.T = "subscription"
        self.trades = trades
        self.quotes = quotes
        self.bars = bars
    }
    
    // the response only contains 1 message in array
    static func loadFromStringArray(_ text: String) -> AlpacaSubscriptionAckMessage?{
        let data = text.data(using: .utf8) ?? Data()
        let t = try? JSONDecoder().decode([AlpacaSubscriptionAckMessage].self, from: data)
        guard let first = t?.first, first.T == "subscription" else {
            return nil
        }
        return first
    }
}
