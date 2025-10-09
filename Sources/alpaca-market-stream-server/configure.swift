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


    app.webSocket("ws") { req, ws in
        req.logger.info("WS connected from \(req.remoteAddress?.description ?? "unknown")")
        
        //TODO: validate auth by http header, then save to session
        guard let id = req.headers.first(name: "app-device-id") else {
            await closeWithAuthErrorResponse(ws)
            return
        }
        
        print("App Websocket Client id: \(id) authenticatd, add to sessions.")
        let session = ClientSession(id: id, ws: ws, config: .init())
//        await hub.addSession(session)
        
        // Text frames: echo back
        ws.onText { ws, text in
            print("✉️ WS text: \(text)")
            //validate ws if authenticated
//            guard let session = await hub.getSessionByWS(ws) else {
//                //reject and close
//                await closeWithAuthErrorResponse(ws)
//                return
//            }
//            
//            //handle subscribe request action
//            if let subscribeRequest = try? AlpacaSubscriptionRequestMessage.loadFromString(text) {
//                let response = AlpacaSubscriptionMessage(trades: subscribeRequest.trades, quotes: subscribeRequest.quotes, bars: subscribeRequest.bars)
//                do {
//                    try await hub.subscribe(id, subscribeRequest)
//                    await session.enqueue(response.jsonString())
//                } catch {
//                    //TODO: hanle what?
//                }
//                
//                return
//            }
//            
//            //distribute market data
//            if !text.isEmpty {
//                await hub.distributeToClientSessions(text)
//            }
        }

        // Binary frames: echo back
        ws.onBinary { ws, buffer in
            print("❌ Not supported WS binary: \(buffer.readableBytes) bytes")
            
        }
        
        //ws.onClose.whenComplete{} is registered in Hub when adding the session, no action here.
        
        
    }
    
    @Sendable func closeWithAuthErrorResponse(_ ws: WebSocket) async {
        print("❌ To close with AuthErrorResponse")
        let error = AlpacaSuccessOrErrorMessage(T: "error", code: 401, msg: "rejected due to not authenticated.")
        try? await ws.send(error.jsonString())
        try? await Task.sleep(for: .seconds(0.5))
        try? await ws.close()
    }
}
