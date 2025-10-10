//
//  AlpacaSuccessOrErrorMessage.swift
//  alpaca-market-stream-server
//
//  Created by Peijun Zhao on 10/10/25.
//

import Foundation

///for connect, authenticate,  error response
struct AlpacaSuccessOrErrorMessage: AlpacaMarketDataMessage {
    let T: String
    let code: Int? //406: connection limit exceeded, 401: not authenticated
    let msg: String? //"connected", authenticated"
    
    static func loadFromString(_ text: String)  -> AlpacaSuccessOrErrorMessage?{
        let data = text.data(using: .utf8) ?? Data()
        let t = try? JSONDecoder().decode([AlpacaSuccessOrErrorMessage].self, from: data)
        guard let first = t?.first, ["success", "error"].contains(first.T)  else {
            return nil
        }
        return first
    }
    
    func jsonString() -> String {
        let data = try? JSONEncoder().encode(self)
        let string = String(data: data ?? Data(), encoding: .utf8) ?? ""
        return string
    }
}
