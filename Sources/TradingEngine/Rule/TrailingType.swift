//
//  TrailingType.swift
//  alpaca-market-stream-server
//
//  Created by Peijun Zhao on 10/13/25.
//


import Foundation

/// Represents the direction of a trailing strategy.
enum TrailingType {
    case sell
    case buy
}

/// Represents the mode: fixed dollar amount or percentage.
enum TrailMode {
    case amount(Double)
    case percent(Double)
}

/// Generic result
enum TrailingAction {
    case none
    case trigger    // should execute order
}

/// A reusable trailing logic structure
struct TrailingOrder {
    let type: TrailingType
    let mode: TrailMode
    
    private(set) var referencePrice: Double    // highest or lowest so far
    private(set) var isTriggered: Bool = false
    
    init(type: TrailingType, mode: TrailMode, initialPrice: Double) {
        self.type = type
        self.mode = mode
        self.referencePrice = initialPrice
    }
    
    /// Evaluate the current market price and update state
    mutating func evaluate(currentPrice: Double) -> TrailingAction {
        guard !isTriggered else { return .none }
        
        switch type {
        case .sell:
            // track highest price
            if currentPrice > referencePrice {
                referencePrice = currentPrice
            }
            // determine trigger level
            let triggerPrice = calculateTriggerPrice(from: referencePrice, for: .sell)
            if currentPrice <= triggerPrice {
                isTriggered = true
                return .trigger
            }
            
        case .buy:
            // track lowest price
            if currentPrice < referencePrice {
                referencePrice = currentPrice
            }
            // determine trigger level
            let triggerPrice = calculateTriggerPrice(from: referencePrice, for: .buy)
            if currentPrice >= triggerPrice {
                isTriggered = true
                return .trigger
            }
        }
        return .none
    }
    
    /// Calculates the trailing trigger threshold
    private func calculateTriggerPrice(from ref: Double, for type: TrailingType) -> Double {
        switch mode {
        case .amount(let amount):
            switch type {
            case .sell: return ref - amount
            case .buy:  return ref + amount
            }
        case .percent(let pct):
            let diff = ref * pct / 100.0
            switch type {
            case .sell: return ref - diff
            case .buy:  return ref + diff
            }
        }
    }
}
