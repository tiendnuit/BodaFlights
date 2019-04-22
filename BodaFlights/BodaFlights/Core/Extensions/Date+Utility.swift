//
//  Date+Utility.swift
//  BodaFlights
//
//  Created by Scor Doan on 4/21/19.
//  Copyright © 2019 Scor Doan. All rights reserved.
//

import Foundation

//MARK: - Date extension
func getTimeComponentString(olderDate older: Date,newerDate newer: Date) -> (String?)  {
    let formatter = DateComponentsFormatter()
    formatter.unitsStyle = .short
    
    let componentsLeftTime = Calendar.current.dateComponents([.minute , .hour , .day,.month, .weekOfMonth,.year], from: older, to: newer)
    
    let year = componentsLeftTime.year ?? 0
    if  year > 0 {
        formatter.allowedUnits = [.year]
        return formatter.string(from: older, to: newer)
    }
    
    
    let month = componentsLeftTime.month ?? 0
    if  month > 0 {
        formatter.allowedUnits = [.month]
        return formatter.string(from: older, to: newer)
    }
    
    let weekOfMonth = componentsLeftTime.weekOfMonth ?? 0
    if  weekOfMonth > 0 {
        formatter.allowedUnits = [.weekOfMonth]
        return formatter.string(from: older, to: newer)
    }
    
    let day = componentsLeftTime.day ?? 0
    if  day > 0 {
        formatter.allowedUnits = [.day]
        return formatter.string(from: older, to: newer)
    }
    
    let hour = componentsLeftTime.hour ?? 0
    if  hour > 0 {
        formatter.allowedUnits = [.hour]
        return formatter.string(from: older, to: newer)
    }
    
    let minute = componentsLeftTime.minute ?? 0
    if  minute > 0 {
        formatter.allowedUnits = [.minute]
        return formatter.string(from: older, to: newer) ?? ""
    }
    
    return nil
}

extension Date {
    func asString(style: DateFormatter.Style = .medium) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = style
        return dateFormatter.string(from: self)
    }
    
    func toString( dateFormat format  : String = "MM/dd/yyyy") -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
    func adding(minutes: Int) -> Date {
        return Calendar.current.date(byAdding: .minute, value: minutes, to: self)!
    }
    
    func adding(days: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(years: Int) -> Date {
        return Calendar.current.date(byAdding: .year, value: years, to: self)!
    }
}

//MARK: - DateFormatter
extension DateFormatter {
    static let LufthansaDateFormatter: DateFormatter = {    //yyyy-MM-ddTHH:mm:ss
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}
