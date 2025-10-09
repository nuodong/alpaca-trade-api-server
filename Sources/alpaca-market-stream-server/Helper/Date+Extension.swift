//
//  File.swift
//  alpaca-market-stream-server
//
//  Created by Peijun Zhao on 10/9/25.
//

import Foundation

enum DateStringFormat: String {
    case `yyyy-MM-dd HH:mm:ss`
    case `yyyy-MM-dd HH:mm:ss.SSS`
    case `yyyy-MM-dd EEE HH:mm:ss.SSS`
    case `HH:mm:ss`
    case `HH:mm:ss.SSS`
}
extension Date {
    func stringFormat(_ format: DateStringFormat, locale: Locale? = .current) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "\(format.rawValue)"
        formatter.locale = locale
        formatter.timeZone = .current
        return formatter.string(from: self)
    }
}
