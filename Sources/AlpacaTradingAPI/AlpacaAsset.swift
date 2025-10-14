//
//  AlpacaAsset.swift
//  alpaca-swift
//
//  Created by Peijun Zhao on 9/25/25.
//

import Foundation
// MARK: AlpacaAsset

/// Tradable asset metadata.
public struct AlpacaAsset: Codable, Hashable, Sendable, Identifiable {
    /// Unique asset ID (UUID).
    public let id: String
    /// Symbol (ticker).
    public let symbol: String
    /// Asset class, e.g., "us_equity", "crypto".
    public let `class`: String
    /// Exchange code (for equities), e.g., "NASDAQ".
    public let exchange: String?
    /// Asset status (e.g., "active", "inactive").
    public let status: String
    /// True if asset is tradable on this account.
    public let tradable: Bool
    /// True if shorting is allowed for this asset.
    public let shortable: Bool
    /// True if margin trading is allowed for this asset.
    public let marginable: Bool
    /// True if fractional trading is supported.
    public let fractionable: Bool
    /// True if easy-to-borrow.
    public let easy_to_borrow: Bool?
}
