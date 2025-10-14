//
//  TradingRule.swift
//  alpaca-market-stream-server
//
//  Created by Peijun Zhao on 10/13/25.
//

import Foundation

public struct TradingRule: Codable, Sendable, Identifiable {
    public var id: String
    public var name: String
    public var subtitle: String
    public var enabled: Int //0: disabled, 1: enabled.
    public var symbol: String
    
    public var timeFilter: TradingTimeFilter
    public var condition: String
    public var actions: [TradingAction]
}
