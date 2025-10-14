//
//  CloseAllResult.swift
//  alpaca-swift
//
//  Created by Peijun Zhao on 9/25/25.
//

import Foundation
/// Result objects returned by DELETE /v2/positions.
public struct CloseAllResult: Codable, Hashable, Sendable {
    /// Symbol that was targeted for closing.
    public let symbol: String
    /// Order ID created to close the position.
    public let order_id: String?
    /// Status text indicating success or reason.
    public let status: String?
}
