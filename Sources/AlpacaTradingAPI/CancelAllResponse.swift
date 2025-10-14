//
//  CancelAllResponse.swift
//  alpaca-swift
//
//  Created by Peijun Zhao on 9/25/25.
//

import Foundation
/// Response object from DELETE /v2/orders (cancel all).
public typealias CancelAllResponse = [CancelAllOrderStatus]

public struct CancelAllOrderStatus: Codable, Hashable, Sendable {
    let id: String
    /// http response code. 200 is success.
    let status: Int
}
