//
//  File.swift
//  
//
//  Created by Tomas Green on 2021-08-03.
//

import Foundation

extension Date {
    private static var _defaultCalendar:Calendar?
    static var defaultCalendar:Calendar {
        if _defaultCalendar == nil {
            var c = Calendar(identifier: Calendar.Identifier.gregorian)
            c.firstWeekday = 2
            self._defaultCalendar = c
        }
        return _defaultCalendar!
    }
    var hour:Int {
        return Date.defaultCalendar.component(.hour, from: self)
    }
}
func relativeDateFrom(time:String,date:Date = Date()) -> Date {
    let month = Calendar.current.component(.month, from: date)
    let year = Calendar.current.component(.year, from: date)
    let day = Calendar.current.component(.day, from: date)
    let str = "\(year)-\(month)-\(day)T\(time)"
    let f = DateFormatter()
    f.dateFormat = "Y-M-d'T'HH:mm"
    
    return f.date(from: str)!
}
func timeStringfrom(date:Date) -> String {
    let f = DateFormatter()
    f.dateFormat = "HH:mm"
    return f.string(from: date)
}
