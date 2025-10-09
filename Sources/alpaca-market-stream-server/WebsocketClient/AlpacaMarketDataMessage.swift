//
//  AlpacaMarketDataMessage.swift
//  AlpacaMarketWebsocketClient
//
//  Created by Peijun Zhao on 10/8/25.
//

import Foundation
typealias StockSymbol = String
protocol AlpacaMarketDataMessage: Codable, Sendable {
    var T: String {get}
}

extension AlpacaMarketDataMessage {
    func jsonString() -> String {
        let data = (try? JSONEncoder().encode(self)) ?? Data()
        let jsonString = String(data: data, encoding: .utf8) ?? ""
        return jsonString
    }
}

///for connect, authenticate
struct AlpacaSuccessOrErrorMessage: AlpacaMarketDataMessage {
    let T: String
    let code: Int? //406: connection limit exceeded, 401: not authenticated
    let msg: String? //"connected", authenticated"
    
    static func loadFromString(_ text: String) throws -> AlpacaSuccessOrErrorMessage?{
        let data = text.data(using: .utf8) ?? Data()
        let t = try JSONDecoder().decode([AlpacaSuccessOrErrorMessage].self, from: data)
        guard let first = t.first, ["success", "error"].contains(first.T)  else {
            return nil
        }
        return first
    }
}


struct AlpacaSubscriptionMessage: AlpacaMarketDataMessage {
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
    
    init() {
        self.T = "subscription"
        self.trades = []
        self.quotes = []
        self.bars = []
    }
    
    // the response only contains 1 message in array
    static func loadFromString(_ text: String) throws -> AlpacaSubscriptionMessage?{
        let data = text.data(using: .utf8) ?? Data()
        let t = try JSONDecoder().decode([AlpacaSubscriptionMessage].self, from: data)
        guard let first = t.first, first.T == "subscription" else {
            return nil
        }
        return first
    }
}

/// caution: if empty, will return nil
struct AlpacaBarMessage: AlpacaMarketDataMessage {
    let T: String //“b: Minute bars”, “d: dailyBars” or “u: updatedBars”
    let S: String
    let o: Double
    let h: Double
    let l: Double
    let c: Double
    let v: Int
    let vw: Double
    let n: Int
    let t: String
    
    
    static func loadFromString(_ text: String) throws -> [AlpacaBarMessage]? {
        let data = text.data(using: .utf8) ?? Data()
        let results = try JSONDecoder().decode([AlpacaBarMessage].self, from: data)
        return results.isEmpty ? nil : results
    }
}

/// caution: if empty, will return nil
struct AlpacaQuoteMessage: AlpacaMarketDataMessage {
    let T: String //always "q"
    let S: String
    let ax: String
    let ap: Double
    let `as`: Int
    let bx: String
    let bp: Double
    let bs: Int
    let c: [String]
    let t: String
    let z: String
    
    static func loadFromString(_ text: String) throws -> [AlpacaQuoteMessage]?{
        let data = text.data(using: .utf8) ?? Data()
        let results = try JSONDecoder().decode([AlpacaQuoteMessage].self, from: data)
        return results.isEmpty ? nil : results
    }
}
/// caution: if empty, will return nil
struct AlpacaTradeMessage: AlpacaMarketDataMessage {
    let T: String //always "t"
    let S: String
    let i: Int
    let x: String
    let p: Double
    let s: Int
    let c: [String]
    let t: String
    let z: String
    
    static func loadFromString(_ text: String) throws -> [AlpacaTradeMessage]?{
        let data = text.data(using: .utf8) ?? Data()
        let results = try JSONDecoder().decode([AlpacaTradeMessage].self, from: data)
        return results.isEmpty ? nil : results
    }
}
