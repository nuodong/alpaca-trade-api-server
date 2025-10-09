//
//  File.swift
//  Alpaca
//
//  Created by Peijun Zhao on 10/8/25.
//

import Foundation

public enum AlpacaError: Error {
    case unsupportedPayload
    case unsupportedMessageType(String)
}
