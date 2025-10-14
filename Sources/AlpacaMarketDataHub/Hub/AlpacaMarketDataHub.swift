//
//  AlpacaMarketDataHub.swift
//  AlpacaMarketWebsocketClient
//
//  Created by Peijun Zhao on 10/8/25.
//

import Vapor

// ===============================
// Hub actor: manages clients + subscriptions
// ===============================

///currently, one 1 alpaca websocket client is used. Call start() once.
///when a app client's websocket is closed, hub will remove it from the sessions
public actor AlpacaMarketDataHub {
    var sessions: [String: ClientSession] = [:]
    //subscribed items from Alpaca
    private var trades: Set<String> = []
    private var quotes: Set<String> = []
    private var bars: Set<String> = []
    private let config = WSConfig()
    
    private var alpaca: AlpacaMarketWebsocketClient
    
    public init(alpaca: AlpacaMarketWebsocketClient) {
        self.alpaca = alpaca
    }
    
    public func start() async throws{
        await alpaca.start { [weak self] in
            //on connected, authenticatd
            guard let self else {return}
            let trades = await self.trades
            let quotes = await self.quotes
            let bars = await self.bars
            //connected and authorized
            //resend subscription if reconnected
            if !trades.isEmpty || !quotes.isEmpty || !bars.isEmpty {
                try await self.alpaca.send(subscription: .init(trades: self.trades.isEmpty ? nil : Array(self.trades), quotes: self.quotes.isEmpty ? nil : Array(self.quotes), bars: self.bars.isEmpty ? nil :  Array(self.bars)))
            }
        } onDisconnect: {
            // do nothing, wait for auto reconnect
        } onReceiveMarketData: {[weak self] text in
            print("* hub start processing the msg")
            guard let self else {return}
            if let message = AlpacaSubscriptionAckMessage.loadFromStringArray(text) {
                print("**** it's a sub ack")
                await updateSubscription(trades: message.trades, quotes: message.quotes, bars: message.bars)
            } else {
                print("**** it's a data msg, to distribute now")
                // other market data, send back to client by checking which clients has which symbols
                await distributeToClientSessions(text)
            }
        }
    }
    
    // lifecycle
    public func addSession(_ session: ClientSession) async {
        let id = session.id
        let ws = session.ws
        ws.onClose.whenComplete { [weak self] _ in
            Task { await self?.removeSession(id: id) }
        }
        await sessions[id]?.close() // replace if duplicate
        sessions[id] = ClientSession(id: id, ws: ws, config: config)
        
        let message = AlpacaSuccessOrErrorMessage(T: "success", code: nil, msg: "connected")
        await sessions[id]?.enqueue(codable: message)
    }
    
    public func removeSession(id: String) async {
        //TODO: remove from Alpaca if any of its subscriptions not shared used by others.

        await sessions.removeValue(forKey: id)?.close()
        print("Client \(id) is removed from hub")
    }
    
    public func getSession(id: String) -> ClientSession? {
        return sessions[id]
    }
    
    /// subscrbe to alpaca if new, save subscribed symbols to client session
    public func subscribe(_ id: String, _ subscription: AlpacaSubscriptionRequestMessage) async throws {
        guard let clientSession = sessions[id] else {
            return
        }
        //the app client always send the whole subsctipion in each request, empty is to unsubscribe all
        //TODO: check and only send not subscribed ones
        //TODO: check unsubscribed data, if the new array from client app is less than old one, it is unsubscribe someone. compare with old one
        try await alpaca.send(subscription: subscription)
        if let trades = subscription.trades, trades.count > 0 {
            self.trades = self.trades.union(trades)
        }
        if let quotes = subscription.quotes, quotes.count > 0 {
            self.quotes = self.quotes.union(quotes)
        }
        if let bars = subscription.bars, bars.count > 0 {
            self.bars = self.bars.union(bars)
        }
        await clientSession.updateSubscription(trades: subscription.trades, quotes: subscription.quotes, bars: subscription.bars)
        //tell client
        let response = AlpacaSubscriptionAckMessage(trades: subscription.trades, quotes: subscription.quotes, bars: subscription.bars)
        await clientSession.enqueue(codable: response)
    }
    
    ///when receive the response from alpaca server, update the subscribed array
    public func updateSubscription(trades: [String]? = nil, quotes: [String]? = nil, bars: [String]? = nil) {
        if let trades {
            self.trades = Set(trades)
        }
        if let quotes {
            self.quotes = Set(quotes)
        }
        if let bars {
            self.bars = Set(bars)
        }
    }
    
    /// distribute to app clients
    public func distributeToClientSessions(_ text: String) async {
        //Alpaca returned market data array may contains different data, different stocks in one websocket response
        //[String] contains the market data json string, such as {"T":"q","S":"BABA","bx":"V","bp":172,"bs":1,"ax":"V","ap":172.43,"as":2,"c":["R"],"z":"A","t":"2025-10-09T18:24:00.412001659Z"}
        var trades: [StockSymbol: [AlpacaTradeMessage]] = [:]
        var quotes: [StockSymbol: [AlpacaQuoteMessage]] = [:]
        var bars: [StockSymbol: [AlpacaBarMessage]] = [:]
        
        //decode into 3 types of array
        if let items = AlpacaTradeMessage.loadFromStringArray(text) {
            for item in items {
                if trades[item.S] == nil {
                    trades[item.S] = [item]
                } else {
                    trades[item.S]?.append(item)
                }
            }
        }
        if let items = AlpacaQuoteMessage.loadFromStringArray(text) {
            for item in items {
                if quotes[item.S] == nil {
                    quotes[item.S] = [item]
                } else {
                    quotes[item.S]?.append(item)
                }
            }
        }
        if let items = AlpacaBarMessage.loadFromStringArray(text) {
            for item in items {
                if bars[item.S] == nil {
                    bars[item.S] = [item]
                } else {
                    bars[item.S]?.append(item)
                }
            }
        }
        
        print("*** decoded: ", trades, quotes, bars)
        
        //distribute to app client
        for session in sessions.values {
            var tradeRecords: [AlpacaTradeMessage] = []
            let commonTradeSymbols = await Set(session.trades).intersection(trades.keys)
            print("*** commonTradeSymbols: ",commonTradeSymbols)
            for symbol in commonTradeSymbols {
                if let array = trades[symbol] {
                    tradeRecords.append(contentsOf:  array)
                }
            }
            if !tradeRecords.isEmpty {
                await session.enqueue(codableArray: tradeRecords)
            }
            
            var quoteRecords: [AlpacaQuoteMessage] = []
            let commonQuoteSymbols = await Set(session.quotes).intersection(quotes.keys)
            for symbol in commonQuoteSymbols {
                if let array = quotes[symbol] {
                    quoteRecords.append(contentsOf:  array)
                }
            }
            if !quoteRecords.isEmpty {
                await session.enqueue(codableArray: quoteRecords)
            }
            
            var barRecords: [AlpacaBarMessage] = []
            let commonBarSymbols = await Set(session.bars).intersection(bars.keys)
            for symbol in commonBarSymbols {
                if let array = bars[symbol] {
                    barRecords.append(contentsOf:  array)
                }
            }
            if !barRecords.isEmpty {
                await session.enqueue(codableArray: barRecords)
            }
        }
    }
}
