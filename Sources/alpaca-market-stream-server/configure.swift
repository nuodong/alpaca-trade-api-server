//
//  config.swift
//  alpaca-market-stream-server
//
//  Created by Peijun Zhao on 10/8/25.
//


import Vapor

// MARK: - Configure
func configure(_ app: Application) throws {
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

        // Text frames: echo back
        ws.onText { ws, text in
            req.logger.debug("WS text: \(text)")
            ws.send("echo: \(text)")
        }

        // Binary frames: echo back
        ws.onBinary { ws, buffer in
            req.logger.debug("WS binary: \(buffer.readableBytes) bytes")
            ws.send(buffer)
        }
        
        ws.onClose.whenComplete { result in
            switch result {
            case .success:
                req.logger.info("WS closed (graceful)")
            case .failure(let error):
                req.logger.warning("WS closed with error: \(error.localizedDescription)")
            }
        }
    }
}
