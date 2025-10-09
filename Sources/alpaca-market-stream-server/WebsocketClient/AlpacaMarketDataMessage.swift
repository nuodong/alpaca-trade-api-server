//
//  AlpacaMarketDataMessage.swift
//  AlpacaMarketWebsocketClient
//
//  Created by Peijun Zhao on 10/8/25.
//


import Foundation

public protocol AlpacaMarketDataMessage: Codable, Sendable {
    var T: String {get}
}

public extension AlpacaMarketDataMessage {
    func jsonString() async -> String {
        let data = (try? JSONEncoder().encode(self)) ?? Data()
        let jsonString = String(data: data, encoding: .utf8) ?? ""
        return jsonString
    }
}

///for connect, authenticate
public final class AlpacaSuccessOrErrorMessage: AlpacaMarketDataMessage {
    public let T: String
    public let code: Int? //406: connection limit exceeded, 401: not authenticated
    public let msg: String? //"connected", authenticated"
    
    public static func loadFromString(_ text: String) throws -> AlpacaSuccessOrErrorMessage?{
        let data = text.data(using: .utf8) ?? Data()
        let t = try JSONDecoder().decode([AlpacaSuccessOrErrorMessage].self, from: data)
        guard let first = t.first, ["success", "error"].contains(first.T)  else {
            return nil
        }
        return first
    }
}


public final class AlpacaSubscriptionMessage: AlpacaMarketDataMessage {
    public let T: String // always "subscription"
    public let trades: [String]?
    public let quotes: [String]?
    public let bars: [String]?
    
    public init( trades: [String]?,quotes: [String]?,bars: [String]?) {
        self.T = "subscription"
        self.trades = trades
        self.quotes = quotes
        self.bars = bars
    }
    
    public init() {
        self.T = "subscription"
        self.trades = []
        self.quotes = []
        self.bars = []
    }
    
    // the response only contains 1 message in array
    public static func loadFromString(_ text: String) throws -> AlpacaSubscriptionMessage?{
        let data = text.data(using: .utf8) ?? Data()
        let t = try JSONDecoder().decode([AlpacaSubscriptionMessage].self, from: data)
        guard let first = t.first, first.T == "subscription" else {
            return nil
        }
        return first
    }
}

/// caution: if empty, will return nil
public final class AlpacaBarMessage: AlpacaMarketDataMessage {
    public let T: String //“b: Minute bars”, “d: dailyBars” or “u: updatedBars”
    public let S: String
    public let o: Double
    public let h: Double
    public let l: Double
    public let c: Double
    public let v: Int
    public let vw: Double
    public let n: Int
    public let t: String
    
    
    public static func loadFromString(_ text: String) throws -> [AlpacaBarMessage]? {
        let data = text.data(using: .utf8) ?? Data()
        let results = try JSONDecoder().decode([AlpacaBarMessage].self, from: data)
        return results.isEmpty ? nil : results
    }
}

/// caution: if empty, will return nil
public final class AlpacaQuoteMessage: AlpacaMarketDataMessage {
    public let T: String //always "q"
    public let S: String
    public let ax: String
    public let ap: Double
    public let `as`: Int
    public let bx: String
    public let bp: Double
    public let bs: Int
    public let c: [String]
    public let t: String
    public let z: String
    
    public static func loadFromString(_ text: String) throws -> [AlpacaQuoteMessage]?{
        let data = text.data(using: .utf8) ?? Data()
        let results = try JSONDecoder().decode([AlpacaQuoteMessage].self, from: data)
        return results.isEmpty ? nil : results
    }
}
/// caution: if empty, will return nil
public final class AlpacaTradeMessage: AlpacaMarketDataMessage {
    public let T: String //always "t"
    public let S: String
    public let i: Int
    public let x: String
    public let p: Double
    public let s: Int
    public let c: [String]
    public let t: String
    public let z: String
    
    public static func loadFromString(_ text: String) throws -> [AlpacaTradeMessage]?{
        let data = text.data(using: .utf8) ?? Data()
        let results = try JSONDecoder().decode([AlpacaTradeMessage].self, from: data)
        return results.isEmpty ? nil : results
    }
}
