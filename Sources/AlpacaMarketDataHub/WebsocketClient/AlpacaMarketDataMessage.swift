//
//  AlpacaMarketDataMessage.swift
//  AlpacaMarketWebsocketClient
//
//  Created by Peijun Zhao on 10/8/25.
//

import Foundation
typealias StockSymbol = String

public protocol AlpacaMarketDataMessage: Codable, Sendable {
    var T: String {get}
}


/// caution: if empty, will return nil
public struct AlpacaBarMessage: AlpacaMarketDataMessage {
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
    
    
    public static func loadFromStringArray(_ text: String) -> [AlpacaBarMessage]? {
        let data = text.data(using: .utf8) ?? Data()
        let results = try? JSONDecoder().decode([AlpacaBarMessage].self, from: data)
        return results
    }
}

/// caution: if empty, will return nil
public struct AlpacaQuoteMessage: AlpacaMarketDataMessage {
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
    
    public static func loadFromStringArray(_ text: String) -> [AlpacaQuoteMessage]?{
        let data = text.data(using: .utf8) ?? Data()
        let results = try? JSONDecoder().decode([AlpacaQuoteMessage].self, from: data)
        return results
    }
}
/// caution: if empty, will return nil
public struct AlpacaTradeMessage: AlpacaMarketDataMessage {
    public let T: String //always "t"
    public let S: String
    public let i: Int
    public let x: String
    public let p: Double
    public let s: Int
    public let c: [String]
    public let t: String
    public let z: String
    
    static func loadFromStringArray(_ text: String) -> [AlpacaTradeMessage]?{
        let data = text.data(using: .utf8) ?? Data()
        let results = try? JSONDecoder().decode([AlpacaTradeMessage].self, from: data)
        return results
    }
}
