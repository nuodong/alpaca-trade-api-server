//
//  WebSocketHub.swift
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
actor WebSocketHub {
    var sessions: [String: ClientSession] = [:]
    //subscribed items from Alpaca
    private var trades: Set<String> = []
    private var quotes: Set<String> = []
    private var bars: Set<String> = []
    private let config = WSConfig()
    
    private var alpaca: AlpacaMarketWebsocketClient
    
    init(alpaca: AlpacaMarketWebsocketClient) {
        self.alpaca = alpaca
    }
    func start() async throws{
        await alpaca.start { [weak self] in
            guard let self else {return}
            //connected and authorized
            //resend subscription if reconnected
            try await self.alpaca.send(subscription: .init(trades: Array(self.trades), quotes: Array(self.quotes), bars: Array(self.bars)))
        } onDisconnect: {
            // do nothing, wait for auto reconnect
        } onReceiveMarketData: {[weak self] text in
            guard let self else {return}
            if let message = try? AlpacaSubscriptionMessage.loadFromString(text) {
                await updateSubscription(trades: message.trades, quotes: message.quotes, bars: message.bars)
            } else {
                // other market data, send back to client by checking which clients has which symbols
                let sessions = await self.sessions
                if let bars = try AlpacaBarMessage.loadFromString(text), let first = bars.first {
                    let symbol = first.S
                    for (_,session) in sessions {
                        if await session.bars.contains(symbol) {
                            try await session.ws.send(text)
                        }
                    }
                }else if let trades = try AlpacaTradeMessage.loadFromString(text), let first = trades.first {
                    let symbol = first.S
                    for (_,session) in sessions {
                        if await session.trades.contains(symbol) {
                            try await session.ws.send(text)
                        }
                    }
                } else if let quotes = try AlpacaQuoteMessage.loadFromString(text), let first = quotes.first {
                    let symbol = first.S
                    for (_,session) in sessions {
                        if await session.quotes.contains(symbol) {
                            try await session.ws.send(text)
                        }
                    }
                } else {
                    print("❌ unknown market data message:\n\(text)")
                }
            }
        }
    }
    
    // lifecycle
    func addSession(_ session: ClientSession) async {
        let id = session.id
        let ws = session.ws
        ws.onClose.whenComplete { [weak self] _ in
            Task { await self?.removeSession(id: id) }
        }
        await sessions[id]?.close() // replace if duplicate
        sessions[id] = ClientSession(id: id, ws: ws, config: config)
        
        let message = AlpacaSuccessOrErrorMessage(T: "success", code: nil, msg: "connected")
        await sessions[id]?.enqueue(message.jsonString())
    }
    
    func removeSession(id: String) async {
        //TODO: remove from Alpaca if any of its subscriptions not shared used by others.

        await sessions.removeValue(forKey: id)?.close()
        
    }
    
    func subscribe(_ id: String, _ subscription: AlpacaSubscriptionRequestMessage) async throws {
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
            self.quotes = self.trades.union(quotes)
        }
        if let bars = subscription.bars, bars.count > 0 {
            self.bars = self.trades.union(bars)
        }
        await clientSession.updateSubscription(trades: subscription.trades, quotes: subscription.quotes, bars: subscription.bars)
        //tell client
        let response = AlpacaSubscriptionMessage(trades: subscription.trades, quotes: subscription.quotes, bars: subscription.bars)
        await sessions[id]?.enqueue(response)
    }
    
    ///when receive the response from alpaca server, update the subscribed array
    func updateSubscription(trades: [String]? = nil, quotes: [String]? = nil, bars: [String]? = nil) {
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
    
}
