//
//  AnyEncodable.swift
//  alpaca-swift
//
//  Created by Peijun Zhao on 9/25/25.
//

import Foundation
/// Type eraser for Encodable bodies
public struct AnyEncodable: Encodable {
    private let encodeFunc: (Encoder) throws -> Void
    public init(_ encodable: Encodable) {
        self.encodeFunc = encodable.encode
    }
    public func encode(to encoder: Encoder) throws { try encodeFunc(encoder) }
}
