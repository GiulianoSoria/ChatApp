//
//  Date+Extensions.swift
//  ChatAppRealm
//
//  Created by Giuliano Soria Pazos on 2021-06-06.
//

import Foundation

extension Date {
  func convertToMonthDayYearFormat() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMM dd, yy @ HH:mm:ss"
    
    return dateFormatter.string(from: self)
  }
}
