//
//  TradingEngine.swift
//  alpaca-market-stream-server
//
//  Created by Peijun Zhao on 10/13/25.
//

import Foundation

public actor TradingEngine {
    public var marketDataSource = MarketDataSource.shared
    public var lastExecution: [String: Date] = [:]
    
    public init() {}
    public func evaluateCondition(rule: TradingRule, data: MarketData) async throws -> Bool {
        guard rule.enabled == 1 else { return false }
        guard try rule.timeFilter.isValidDate() else { return false }
        
        
        //TODO: Evaluate
        
        return true
    }
    
    public func start() {
        
    }
    
}
