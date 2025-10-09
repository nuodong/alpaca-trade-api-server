//
//  AlpacaMarketWebsocketClient.swift
//  WebSocketClientDemo
//
//  Created by Peijun Zhao on 10/7/25.
//

import Vapor
import NIOCore

///This API connectes to Alpaca  WebSocket stream for real-time market data.
actor AlpacaMarketWebsocketClient {
    private let apiKey: String
    private let apiSecret: String
    
    var url: String
    let pingInterval: Int64 = 30
    
    var isConnected = false
    var isAuthenticated = false
    
    private var websocket: WebSocket? = nil
    
    enum Feed: String {
        case test
        case iex
        case iex_extended
        ///paid subscription needed
        case sip
        
    }
    init(apiKey: String, apiSecret: String, feed: Feed) {
        self.apiKey = apiKey
        self.apiSecret = apiSecret
        self.url = "wss://stream.data.alpaca.markets/v2/\(feed.rawValue)"
    }
    
    private func setWebSocket(_ webSocket: WebSocket) {
        self.websocket = webSocket
    }
    private func setAuthenticated(_ isAuthenticated: Bool) {
        self.isAuthenticated = isAuthenticated
    }
    private func setConnected(_ isConnected: Bool) {
        self.isConnected = isConnected
    }
    /// Auto connect, auto retry. Check property isAuthorzied before sending commands.
    func start(onConnect: @escaping @Sendable () async throws -> Void, onDisconnect: @escaping @Sendable () async throws -> Void, onReceiveMarketData: @escaping @Sendable (String) async throws-> Void) {
        Task {[weak self ] in
            while true {
                guard let self else {return}
                if await !self.isConnected {
                    try await self._connect(onConnect: onConnect, onDisconnect: onDisconnect, onReceiveMarketData: onReceiveMarketData)
                }
                try await Task.sleep(for: .seconds(10))
            }
        }
    }
    
    private func _connect(onConnect: @escaping @Sendable () async throws->Void, onDisconnect: @escaping @Sendable () async throws->Void, onReceiveMarketData: @escaping @Sendable (String) async throws->Void) async throws {
        let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        WebSocket.connect(to: url, on: group.next()) { [weak self] ws in
            guard let self else {return}
            print("✅ Alpaca websocket connected.")
            ws.pingInterval = .seconds(self.pingInterval)
            
            Task {[weak self]  in
                guard let self else {return}
                await self.setWebSocket(ws)
                await self.setConnected(true)
                try await Task.sleep(for: .seconds(1))
                //send auth
                let auth = #"{"action":"auth","key":"\#(self.apiKey)","secret":"\#(self.apiSecret)"}"#
                try await ws.send(auth)
            }
            
            ws.onText {[weak self] ws, text in
                guard let self else {return}
                print("📩", text)
                
                do {
                    
                    //handle connect , authentication, error here. Let callback handle others
                    if let message = try? AlpacaSuccessOrErrorMessage.loadFromString(text) {
                        if message.T == "success", message.msg == "connected" {
                            //do nothing
                        } else if message.T == "success", message.msg == "authenticated" {
                            Task { [weak self] in
                                await self?.setAuthenticated(true)
                                try await onConnect()
                            }
                        } else if message.T == "error" {
                            print("stop websocket due to error.")
                            Task { [weak self] in
                                await self?.stop()
                            }
                        } else {
                            print("❌ Error, Unknow AlpacaSuccessOrErrorMessage \(message)")
                        }
                    } else {
                        try await onReceiveMarketData(text)
                    }
                    
                } catch {
                    print("❌ Error, stop websocket due to exception.")
                    Task { [weak self] in
                        await self?.stop()
                    }
                }
            }
            
            ws.onBinary { _, buff in
                print("📩 binary (\(buff.readableBytes) bytes)")
            }
            ws.onClose.whenComplete {[weak self] _ in
                guard let self else {return}
                print("🛑 Alpaca websocket closed")
                Task { [weak self] in
                    await self?.clean()
                    try await onDisconnect()
                }
                
            }
            
        }.whenFailure { error in
            print("❌ Alpaca websocket connect error:", error)
            Task { [weak self] in
                await self?.clean()
            }
        }
        
    }
    
    func send(_ string: String) async throws{
        try await self.websocket?.send(string)
    }
    
    func send(dict: [String: Any]) async throws {
        if let data = try? JSONSerialization.data(withJSONObject: dict, options: []),
           let jsonString = String(data: data, encoding: .utf8) {
            try await self.websocket?.send(jsonString)
        }
    }
    
    func send(subscription: SubscriptionRequestMessage) async throws {
        let jsonString = await subscription.jsonString()
        try await self.websocket?.send(jsonString)
    }
    
    
    ///reset state and clean resources
    private func clean() {
        self.isConnected = false
        self.isAuthenticated = false
        self.websocket = nil
    }
    
    func stop() {
        let _ = self.websocket?.close(promise: nil)
        self.clean()
    }
    
    
}
