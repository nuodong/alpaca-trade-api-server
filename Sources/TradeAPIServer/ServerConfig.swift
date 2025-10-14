//
//  ServerConfig.swift
//  alpaca-market-stream-server
//
//  Created by Peijun Zhao on 10/14/25.
//

import Foundation

struct ServerConfig: Codable {
    let alpacapaperaccount: AlpacaAccountConfig
    let alpacaliveaccount: AlpacaAccountConfig
    
    static func load(configFile: String) throws -> ServerConfig{
        let data = try Data(contentsOf: .init(filePath: configFile))
        let obj = try JSONDecoder().decode(ServerConfig.self, from: data)
        return obj
    }
}


struct AlpacaAccountConfig: Codable {
    let alpaca_api_key: String
    let alpaca_api_secret: String
}
