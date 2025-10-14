//
//  TimeInForce.swift
//  alpaca-swift
//
//  Created by Peijun Zhao on 9/25/25.
//

import Foundation
public enum TimeInForce: String, Codable, Hashable, Sendable {
    /// Day order (expires end of market day).
    case day = "day"
    /// Good-til-canceled.
    case gtc = "gtc"
    /// Immediate-or-cancel.
    case ioc = "ioc"
    /// Fill-or-kill.
    case fok = "fok"
    /// Good-til-date (use `expire_at`).
    case gtd = "gtd"
    /// Extended hours only.
    case opg = "opg"
}
