//
//  AlpacaSuccessOrErrorMessage.swift
//  alpaca-market-stream-server
//
//  Created by Peijun Zhao on 10/10/25.
//

import Foundation

///for connect, authenticate,  error response
public struct AlpacaSuccessOrErrorMessage: AlpacaMarketDataMessage {
    public let T: String
    public let code: Int? //406: connection limit exceeded, 401: not authenticated
    public let msg: String //"connected", authenticated"
    
    public init(T: String, code: Int?, msg: String) {
        self.T = T
        self.code = code
        self.msg = msg
    }
    public static func loadFromString(_ text: String)  -> AlpacaSuccessOrErrorMessage?{
        let data = text.data(using: .utf8) ?? Data()
        let t = try? JSONDecoder().decode([AlpacaSuccessOrErrorMessage].self, from: data)
        guard let first = t?.first, ["success", "error"].contains(first.T)  else {
            return nil
        }
        return first
    }
    
    public func jsonString() -> String {
        let data = try? JSONEncoder().encode(self)
        let string = String(data: data ?? Data(), encoding: .utf8) ?? ""
        return string
    }
}
