//
//  ClosePositionSide.swift
//  alpaca-swift
//
//  Created by Peijun Zhao on 9/25/25.
//

import Foundation
/// Optional side hint for closing positions (some endpoints allow specifying).
public enum ClosePositionSide: String, Codable, Hashable, Sendable {
    case buy
    case sell
}
