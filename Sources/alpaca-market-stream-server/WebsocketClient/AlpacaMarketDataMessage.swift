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
    
    
    static func loadFromStringArray(_ text: String) -> [AlpacaBarMessage]? {
        let data = text.data(using: .utf8) ?? Data()
        let results = try? JSONDecoder().decode([AlpacaBarMessage].self, from: data)
        return results
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
    
    static func loadFromStringArray(_ text: String) -> [AlpacaQuoteMessage]?{
        let data = text.data(using: .utf8) ?? Data()
        let results = try? JSONDecoder().decode([AlpacaQuoteMessage].self, from: data)
        return results
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
    
    static func loadFromStringArray(_ text: String) -> [AlpacaTradeMessage]?{
        let data = text.data(using: .utf8) ?? Data()
        let results = try? JSONDecoder().decode([AlpacaTradeMessage].self, from: data)
        return results
    }
}
