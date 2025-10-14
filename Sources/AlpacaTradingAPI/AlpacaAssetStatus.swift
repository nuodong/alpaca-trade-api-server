//
//  AlpacaAssetStatus.swift
//  alpaca-swift
//
//  Created by Peijun Zhao on 9/25/25.
//

import Foundation
public enum AlpacaAssetStatus: String, Codable, Hashable, Sendable {
    /// Active assets available for trading.
    case active
    /// Inactive assets.
    case inactive
}
