//
//  ClientSession.swift
//  AlpacaMarketWebsocketClient
//
//  Created by Peijun Zhao on 10/8/25.
//


// ===============================
// Per-client bounded session (AsyncStream)
// ===============================
import Vapor

///This is the websocet session from App client to this server.
actor ClientSession {
    let id: String
    let ws: WebSocket
    private let config: WSConfig
    
    private let stream: AsyncStream<String>
    private let continuation: AsyncStream<String>.Continuation
    
    private var drainTask: Task<Void, Never>?

    var trades: [StockSymbol] = []
    var quotes: [StockSymbol] = []
    var bars: [StockSymbol] = []
    
    init(id: String, ws: WebSocket, config: WSConfig) {
        self.id = id
        self.ws = ws
        self.config = config
        
        var cont: AsyncStream<String>.Continuation!
        self.stream = AsyncStream<String>(bufferingPolicy: .bufferingNewest(config.queueCapacity)) { c in
            cont = c
        }
        self.continuation = cont
        Task {
            await startDrain()
        }
    }
    
    deinit {
        continuation.finish()
    }
    
    func enqueue(_ msg: String) {
        print("enqueue message to alpaca: ", msg)
        continuation.yield(msg)
    }
    
    func enqueue(_ subscriptionResponse: AlpacaSubscriptionMessage) async{
        enqueue(subscriptionResponse.jsonString())
    }
    
    func enqueue(_ dataArray: [String]) async{
        let data = try? JSONEncoder().encode(dataArray)
        let json = String(data: data ?? Data(), encoding: .utf8) ?? ""
        enqueue(json)
    }

    
    func updateSubscription(trades: [String]? = nil, quotes: [String]? = nil, bars: [String]? = nil) {
        if let trades {self.trades = trades}
        if let quotes {self.quotes = quotes}
        if let bars {self.bars = bars}
    }
    
    private func startDrain() {
        let logger = Logger(label: "ws.client.\(id)")
        var timeoutStrikes = 0
        let maxTimeoutStrikes = 3
        
        drainTask = Task.detached { [weak self] in
            guard let self else { return }
            defer {
                if !self.ws.isClosed { self.ws.close(promise: nil) }
                self.continuation.finish()
            }
            for await msg in self.stream {
                if Task.isCancelled { break }
                do {
                    try await withTimeout(self.config.writeTimeout) {
                        self.ws.send(msg)
                    }
                    timeoutStrikes = 0
                } catch is CancellationError {
                    logger.debug("send cancelled for \(self.id)")
                    break
                } catch let abort as AbortError where abort.status == .requestTimeout {
                    timeoutStrikes += 1
                    logger.warning("write timeout (\(timeoutStrikes)) for \(self.id)")
                    if self.config.disconnectOnOverflow || timeoutStrikes >= maxTimeoutStrikes {
                        logger.error("disconnecting \(self.id) due to repeated timeouts")
                        break
                    } else {
                        continue
                    }
                } catch {
                    logger.error("write failed for \(self.id): \(error.localizedDescription)")
                    break
                }
            }
        }
    }
    
    func close() {
        continuation.finish()
        ws.close(promise: nil)
        drainTask?.cancel()
    }
}
