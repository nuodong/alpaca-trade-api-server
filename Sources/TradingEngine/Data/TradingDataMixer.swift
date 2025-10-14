//
//  TradingDataMixer.swift
//  alpaca-market-stream-server
//
//  Created by Peijun Zhao on 10/13/25.
//

public actor TradingDataMixer {
    public static let shared = TradingDataMixer()
    
    public var marketDataStream: AsyncStream<MarketData>
    private var marketDataStreamContinuation: AsyncStream<MarketData>.Continuation
    
    public init() {
        var cont: AsyncStream<MarketData>.Continuation!
        let steam: AsyncStream<MarketData> = .init { continuation in
            cont = continuation
        }
        self.marketDataStreamContinuation = cont
        self.marketDataStream = steam
    }
    public func addNewData(_ value: MarketData) {
        marketDataStreamContinuation.yield(value)
    }
    public func finish() {
        marketDataStreamContinuation.finish()
    }
}
