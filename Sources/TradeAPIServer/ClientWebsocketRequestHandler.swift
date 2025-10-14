//
//  File.swift
//  alpaca-market-stream-server
//
//  Created by Peijun Zhao on 10/14/25.
//

import Foundation
import Vapor
import AlpacaMarketDataHub

/// To handle the ws request from app client to trader api server
struct ClientWebsocketRequestHandler {
    static func handleAppClientWSRequest(id: String, hub: AlpacaMarketDataHub, ws: WebSocket, text: String) async {
        print(" WS text (id: \(id): \(text)")
        //validate ws if authenticated
        guard let _ = await hub.getSession(id: id) else {
            //reject and close
            print("not found the websocket session, to close it.")
            await closeWithAuthErrorResponse(ws)
            return
        }
        
        //handle subscribe request action
        if let subscribeRequest = AlpacaSubscriptionRequestMessage.loadFromString(text) {
            do {
                print("**** hub to add subscription \(subscribeRequest) for client: ", id)
                try await hub.subscribe(id, subscribeRequest)
            } catch {
                //TODO: hanle what?
            }
        } else {
            print("❌ not recognized text from app client:  \(text) ")
        }
    }
    
    @Sendable static func closeWithAuthErrorResponse(_ ws: WebSocket) async {
        print("❌ To close with AuthErrorResponse")
        let error = AlpacaSuccessOrErrorMessage(T: "error", code: 401, msg: "rejected due to not authenticated.")
        try? await ws.send(error.jsonString())
        try? await Task.sleep(for: .seconds(0.5))
        try? await ws.close()
    }

}
