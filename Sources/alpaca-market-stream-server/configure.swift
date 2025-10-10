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
        //All async functons are not allowed in this level, otherwise server will crash
        guard let id = req.headers.first(name: "app-device-id") else {
            Task {
                await closeWithAuthErrorResponse(ws)
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
            print(" WS text (id: \(id): \(text)")
            //validate ws if authenticated
            guard let _ = await hub.getSession(id: id) else {
                //reject and close
                print("not found the websocket session, to close it.")
                await closeWithAuthErrorResponse(ws)
                return
            }
            
            //handle subscribe request action
            if let subscribeRequest = try? AlpacaSubscriptionRequestMessage.loadFromString(text) {
                do {
                    try await hub.subscribe(id, subscribeRequest)
                } catch {
                    //TODO: hanle what?
                }
            } else {
                print("❌ not recognized text from app client:  \(text) ")
            }

        }

        // Binary frames: echo back
        ws.onBinary { ws, buffer in
            print("❌ Not supported WS binary: \(buffer.readableBytes) bytes")
            
        }
        
        //ws.onClose.whenComplete{} is registered in Hub when adding the session, no action here.
    }
}

func closeWithAuthErrorResponse(_ ws: WebSocket) async {
    print("❌ To close with AuthErrorResponse")
    let error = AlpacaSuccessOrErrorMessage(T: "error", code: 401, msg: "rejected due to not authenticated.")
    try? await ws.send(error.jsonString())
    try? await Task.sleep(for: .seconds(0.5))
    try? await ws.close()
}
