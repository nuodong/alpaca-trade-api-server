//
//  config.swift
//  alpaca-market-stream-server
//
//  Created by Peijun Zhao on 10/8/25.
//


import Vapor
import AlpacaMarketDataHub

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
        //All async functons are not allowed in this level, otherwise server will crash
        guard let id = req.headers.first(name: "app-device-id") else {
            Task {
                await ClientWebsocketRequestHandler.closeWithAuthErrorResponse(ws)
            }
            return
        }
        
        Task {
            print("App Websocket Client id: \(id) authenticatd, add to sessions.")
            let session = ClientSession(id: id, ws: ws, config: .init())
            await hub.addSession(session)
        }
        
        
        // Text frames: echo back
        ws.onText { ws, text in
            await ClientWebsocketRequestHandler.handleAppClientWSRequest(id: id, hub: hub, ws: ws, text: text)

        }

        // Binary frames: echo back
        ws.onBinary { ws, buffer in
            print("❌ Not supported WS binary: \(buffer.readableBytes) bytes")
            
        }
        
        //ws.onClose.whenComplete{} is registered in Hub when adding the session, no action here.
    }


}


