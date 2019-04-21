//
//  Date+Utility.swift
//  BodaFlights
//
//  Created by Scor Doan on 4/21/19.
//  Copyright © 2019 Scor Doan. All rights reserved.
//

import Foundation

//MARK: - Date extension
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
