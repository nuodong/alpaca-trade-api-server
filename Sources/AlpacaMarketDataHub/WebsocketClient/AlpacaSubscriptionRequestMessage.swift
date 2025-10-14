//
//  AlpacaSubscriptionRequestMessage.swift
//  AlpacaMarketWebsocketClient
//
//  Created by Peijun Zhao on 10/8/25.
//
import Foundation

///Alpaca server will append these new values to existing ones
public struct AlpacaSubscriptionRequestMessage: Codable,Sendable {
    public var action: String = "subscribe"
    public var trades: [String]? = nil
    public var quotes: [String]? = nil
    public var bars: [String]? = nil
    
    public init( trades: [String]? = nil, quotes: [String]? = nil, bars: [String]? = nil) {
        self.trades = trades
        self.quotes = quotes
        self.bars = bars
    }
    public func jsonString() async -> String {
        let data = (try? JSONEncoder().encode(self)) ?? Data()
        let jsonString = String(data: data, encoding: .utf8) ?? ""
        return jsonString
    }
    
    public static func loadFromString(_ text: String) -> AlpacaSubscriptionRequestMessage?{
        let data = text.data(using: .utf8) ?? Data()
        let message = try? JSONDecoder().decode(AlpacaSubscriptionRequestMessage.self, from: data)
        guard message?.action == "subscribe" else {
            return nil
        }
        return message
    }
}
