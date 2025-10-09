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
@MainActor
class WebSocketHub {
    private var clients: [String: ClientSession] = [:]
    //subscribed items from Alpaca
    private var trades: Set<String> = []
    private var quotes: Set<String> = []
    private var bars: Set<String> = []
    
    private let config = WSConfig()
    
    // Upstream hook (set by App after init)
    private weak var alpaca: AlpacaMarketWebsocketClient?
    
    func attach(alpaca: AlpacaMarketWebsocketClient) {
        self.alpaca = alpaca
    }
    func start() async throws{
        await alpaca?.start { [weak self] in
            guard let self else {return}
            //connected and authorized
            //resend subscription if reconnected
            try await self.alpaca?.send(subscription: .init(trades: Array(self.trades), quotes: Array(self.quotes), bars: Array(self.bars)))
        } onDisconnect: {
            // do nothing, wait for auto reconnect
        } onReceiveMarketData: {[weak self] text in
            guard let self else {return}
            if let subscripitionMessage = try? AlpacaSubscriptionMessage.loadFromString(text) {
                await MainActor.run {
                    self.trades = Set(subscripitionMessage.trades ?? [])
                    self.quotes = Set(subscripitionMessage.quotes ?? [])
                    self.bars = Set(subscripitionMessage.bars ?? [])
                }
            } else {
                //market data, send back to client by checking which clients has which symbols
                try await MainActor.run {
                    if let bars = try AlpacaBarMessage.loadFromString(text), let first = bars.first {
                        let symbol = first.S
                        for (_,session) in clients {
                            if session.bars.contains(symbol) {
                                session.ws.send(text)
                            }
                        }
                    } else if let trades = try AlpacaTradeMessage.loadFromString(text), let first = trades.first {
                        let symbol = first.S
                        for (_,session) in clients {
                            if session.trades.contains(symbol) {
                                session.ws.send(text)
                            }
                        }
                    } else if let quotes = try AlpacaQuoteMessage.loadFromString(text), let first = quotes.first {
                        let symbol = first.S
                        for (_,session) in clients {
                            if session.quotes.contains(symbol) {
                                session.ws.send(text)
                            }
                        }
                    }
                }
            }
        }

    }
    
    // lifecycle
    func add(id: String, ws: WebSocket) {
        ws.onClose.whenComplete { [weak self] _ in
            Task { await self?.remove(id: id) }
        }
        clients[id]?.close() // replace if duplicate
        clients[id] = ClientSession(id: id, ws: ws, config: config)
        clients[id]?.enqueue("connected")
    }
    
    func remove(id: String)  {
        clients.removeValue(forKey: id)?.close()
        
        //TODO: remove from Alpaca if any of its subscriptions not shared used by others.
    }
    
    func subscribe(_ id: String, _ subscription: AlpacaSubscriptionRequestMessage) async throws {
        guard let client = clients[id] else {
            return
        }
        //the app client always send the whole subsctipion in each request, empty is to unsubscribe all
        //TODO: check if needed to send if not cached
        try await alpaca?.send(subscription: subscription)
        if let trades = subscription.trades, trades.count > 0 {
            self.trades = self.trades.union(trades)
            client.trades = Set(trades)
        }
        if let quotes = subscription.quotes, quotes.count > 0 {
            self.quotes = self.trades.union(quotes)
            client.quotes = Set(quotes)
        }
        if let bars = subscription.bars, bars.count > 0 {
            self.bars = self.trades.union(bars)
            client.bars = Set(bars)
        }
        //tell client
        let response = AlpacaSubscriptionMessage(trades: subscription.trades, quotes: subscription.quotes, bars: subscription.bars)
        await clients[id]?.enqueue(response)
    }
    
    
}
