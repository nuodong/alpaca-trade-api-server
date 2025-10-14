//
//  MarketDataIndicator.swift
//  alpaca-market-stream-server
//
//  Created by Peijun Zhao on 10/13/25.
//

import Foundation
public enum MarketDataIndicator: String, Codable, Sendable {
    case SYMBOL
    case ASSET //OPTION, STOCK
    case WEEKDAY //1(Monday),2,3,4,5,6,7
    case TIME // 12:00:00, 09:15:30
    case PRICE //current trading price,
    case BARPRICE //last 1 minutes bar close price
    case OPEN //today's open price
    case CLOSE //last day close price
}

