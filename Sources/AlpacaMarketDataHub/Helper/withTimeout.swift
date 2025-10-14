//
//  File.swift
//  AlpacaMarketWebsocketClient
//
//  Created by Peijun Zhao on 10/8/25.
//


// ===============================
// Timeout helper
// ===============================
import Vapor

@discardableResult
func withTimeout<T: Sendable>(
    _ timeout: Duration,
    operation: @escaping @Sendable () async throws -> T
) async throws -> T {
    try await withThrowingTaskGroup(of: T.self) { group in
        group.addTask { try await operation() }
        group.addTask {
            try await Task.sleep(for: timeout)
            throw Abort(.requestTimeout, reason: "WebSocket write timed out")
        }
        defer { group.cancelAll() }
        guard let result = try await group.next() else { throw Abort(.requestTimeout) }
        return result
    }
}
