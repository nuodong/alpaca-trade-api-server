//
//  TradingTimeFilter.swift
//  alpaca-market-stream-server
//
//  Created by Peijun Zhao on 10/13/25.
//
import Foundation

public struct TradingTimeFilter: Codable, Sendable {
    public var startDay: String // ISO 2025-12-21
    public var endDay: String
    public var startTime: String //IOS FORMAT: 13:20:59
    public var endTime: String
    
    /// Returns start and end Date objects in New York time (auto DST aware)
    public func dateRangeNewYork() throws-> (startDate: Date, endDate: Date)  {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(identifier: "America/New_York") // ✅ auto-handles DST
        
        let startString = "\(startDay) \(startTime)"
        let endString   = "\(endDay) \(endTime)"
        
        guard let startDate = formatter.date(from: startString) else {
            throw TradingEngineError.inputTimeError(startString)
        }
        guard let endDate   = formatter.date(from: endString) else {
            throw TradingEngineError.inputTimeError(endString)
        }
        return (startDate, endDate)
    }
    
    public func isValidDate() throws -> Bool {
        let range = try dateRangeNewYork()
        let now = Date()
        return now >= range.startDate && now <= range.endDate
    }
}

