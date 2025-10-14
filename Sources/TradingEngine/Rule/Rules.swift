
//  Rules.swift
//  TradingAutomation
//
//  Created by Richard on 2025-10-12.
//

import Foundation

public enum TradingAmountType: String, Codable, Sendable {
    case item = "ITEM" //stock number, or options batch
    case cash = "CASH" //the most cash amount
}

public enum TradingAssetType: String, Codable, Sendable {
    case equity      // Stocks, ETFs
    case option      // Options on equities or indexes
//    case crypto      // Cryptocurrencies
//    case forex       // Currency pairs (e.g., EUR/USD)
//    case future      // Futures contracts
//    case bond        // Government or corporate debt
}

public enum TradingOrderType: String, Codable, Sendable {
    case marketBuy = "MARKETBUY"
    case limitBuy  = "LIMITBUY"
    case trailBuy = "TRAILBUY"
    case marketSell = "MARKETSELL"
    case limitSell = "LIMITSELL"
    case trailSell = "TRAILSELL"
}

public struct TradingTrailValue: Codable, Sendable {
    //only one exist at a time
    public var trailingAmount: Double? //3 is $3
    public var trailingPercent: Double? // 3 is 3%.
    public var optionTargetPrice: Double? //for option only
}

public struct TradingAction: Codable, Sendable {
    public var orderType: TradingOrderType
    public var trailValue: TradingTrailValue? //only exist for order type TRAILBUY TRAILSELL
    public var delaySeconds: Int //delay x seconds before take action.
    public var amountType: TradingAmountType
    public var amountValue: Double //how many to sell/buy
    
}

