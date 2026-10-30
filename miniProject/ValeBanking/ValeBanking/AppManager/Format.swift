//
//  Format.swift
//  ValeBanking
//
//  Created by Sokunsana Ly on 30/10/2026.
//

import Foundation

enum Format{
    
    private static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.locale = Locale(identifier: "en_US")
        return formatter
    }()
    
    private static let apiDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    private static let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "MMM d"
        return formatter
    }()
    
    private static let headerDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter
    }()

    static func money(_ value: Double) -> String {
        currencyFormatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }
    
    static func signedMoney(_ value: Double) -> String {
        (value < 0 ? "-" : "+") + money(abs(value))
    }
    
    static func shortDate(_ apiDate: String) -> String {
        guard let date = apiDateFormatter.date(from: apiDate)
        else {
            return apiDate
        }
        return shortDateFormatter.string(from: date)
    }
    
    static func todayHeader(_ date: Date = Date()) -> String{
        headerDateFormatter.string(from: date).uppercased()
    }
    
    static func greeting(_ date: Date = Date()) -> String{
        switch Calendar.current.component(.hour, from: date) {
            case 5..<12: return "Morning"
            case 12..<17: return "Afternoon"
            default: return "Evening"
        }
    }
    
    static func masked(_ last4: String) -> String{
        "•• \(last4)"
    }    
}
