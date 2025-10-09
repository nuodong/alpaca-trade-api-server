//
//  AlpacaSubscriptionRequestMessage.swift
//  AlpacaMarketWebsocketClient
//
//  Created by Peijun Zhao on 10/8/25.
//
import Foundation

///Alpaca server will append these new values to existing ones
struct AlpacaSubscriptionRequestMessage: Codable,Sendable {
    var action: String = "subscription"
    var trades: [String]? = nil
    var quotes: [String]? = nil
    var bars: [String]? = nil
    
    func jsonString() async -> String {
        let data = (try? JSONEncoder().encode(self)) ?? Data()
        let jsonString = String(data: data, encoding: .utf8) ?? ""
        return jsonString
    }
}
