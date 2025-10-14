//
//  AlpacaError.swift
//  alpaca-swift
//
//  Created by Peijun Zhao on 9/25/25.
//

import Foundation
// MARK: Errors

public enum AlpacaError: Error, LocalizedError {
    case network(description: String)
    case http(status: Int, body: String)
    case api(APIError, status: Int)

    public var errorDescription: String? {
        switch self {
        case .network(let d): return d
        case .http(let s, let b): return "HTTP \(s): \(b)"
        case .api(let e, let s):  return "API \(s): \(e.message)"
        }
    }
}

/// Standard error object returned by Alpaca REST API.
public struct APIError: Codable, Sendable {
    /// Numeric or string error code identifying the error category.
    public let code: String?
    /// Human-readable error message.
    public let message: String
}
