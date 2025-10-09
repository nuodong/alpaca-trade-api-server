//
//  config.swift
//  alpaca-market-stream-server
//
//  Created by Peijun Zhao on 10/8/25.
//


import Vapor

// MARK: - Configure
func configure(_ app: Application, _ hub: WebSocketHub) throws {
    // Listen on all interfaces, port 8080
    app.http.server.configuration.address = .hostname("0.0.0.0", port: 8080)

    // Simple health endpoint
    app.get { _ in
        "OK"
    }

    app.get("hello") { _ in
        "Hello, Vapor!"
    }

    // WebSocket echo at ws://<host>:8080/ws
    app.webSocket("ws") { req, ws in
        req.logger.info("WS connected from \(req.remoteAddress?.description ?? "unknown")")
        //TODO: get client id
        let id = "001"
        
        // Text frames: echo back
        ws.onText { ws, text in
            req.logger.debug("WS text: \(text)")
            
            
            //TODO: handle authentication
            let session = ClientSession(id: id, ws: ws, config: .init())
            await hub.addSession(session)
            
            //handle subscribe
            if let subscribeRequest = try? AlpacaSubscriptionRequestMessage.loadFromString(text) {
                let response = AlpacaSubscriptionMessage(trades: subscribeRequest.trades, quotes: subscribeRequest.quotes, bars: subscribeRequest.bars)
                do {
                    try await hub.subscribe(id, subscribeRequest)
                    await session.enqueue(response.jsonString())
                } catch {
                    //TODO: hanle what?
                }
            }
            
        }

        // Binary frames: echo back
        ws.onBinary { ws, buffer in
            req.logger.debug("❌ Not supported WS binary: \(buffer.readableBytes) bytes")
            
        }
        
        //ws.onClose.whenComplete{} is registered in Hub when adding the session, no action here.
        
        
    }
}
