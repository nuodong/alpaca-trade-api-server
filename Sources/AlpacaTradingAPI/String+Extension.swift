//
//  String+Extension.swift
//  alpaca-swift
//
//  Created by Peijun Zhao on 9/25/25.
//
import Foundation

public extension String {
    func prettyPrintedJsonString() -> String {
        guard let data = self.data(using: .utf8) else { return self }
        
        do {
            let object = try JSONSerialization.jsonObject(with: data, options: [])
            let prettyData = try JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted])
            return String(data: prettyData, encoding: .utf8) ?? self
        } catch {
            return self
        }
    }

}
