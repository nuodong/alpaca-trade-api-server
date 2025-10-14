//
//  AlpacaOrderClass.swift
//  alpaca-swift
//
//  Created by Peijun Zhao on 9/25/25.
//

import Foundation
public enum AlpacaOrderClass: String, Codable, Hashable, Sendable {
    /// Simple single-leg order, this value may be empty string ""
    case simple
    /// Bracket order (with take-profit & stop-loss).
    case bracket
    /// One-cancels-other.
    case oco
    /// One-triggers-other.
    case oto
    ///mleg (required for multi-leg complex option strategies)
    case mleg
    
    ///allow empty string to init the .simple
    public init(from decoder: Decoder) throws {
            let c = try decoder.singleValueContainer()
            let s = try c.decode(String.self)
            if s.isEmpty { self = .simple }
            else if let v = AlpacaOrderClass(rawValue: s) { self = v }
            else {
                throw DecodingError.dataCorruptedError(
                    in: c, debugDescription: "Invalid OrderClass: \(s)"
                )
            }
        }
}
