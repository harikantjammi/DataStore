//
//  MuhurthamsDTO.swift
//  PocketPanchangApp
//
//  Created by Harikant Jammi on 27/03/25.
//

import Foundation

nonisolated public struct MuhurthamsDTO: Codable, Sendable {
    public let data: Data
    
    public struct Data: Codable, Sendable {
        public let data: Data
        public struct Data: Codable, Sendable {
            public let muhurat: [Muhurthams]
            
            public struct Muhurthams: Codable, Sendable {
                public let id: Int
                public let name: String
                public let type: String
                public let period: [Period]
                
                public struct Period: Codable, Sendable {
                    public let start: Date
                    public let end: Date
                }
            }
        }
    }
}
import SwiftUI

public extension MuhurthamsDTO.Data.Data.Muhurthams {
    var isAuspiscious: Bool {
        self.type.lowercased() == "auspicious"
    }
    
    var tint: Color {
        isAuspiscious ? Color.green : Color.red
    }
    
    var dateInterval: DateInterval? {
        guard let firstPeriod = self.period.first else { return nil }
        return DateInterval(start: firstPeriod.start, end: firstPeriod.end)
    }
    
    static func buildValueLabelText(dateInterval: DateInterval, timeZone: String) -> String {
        var onlyTimeFormatStyle = Date.FormatStyle().hour().minute()
        onlyTimeFormatStyle.timeZone = TimeZone(identifier: timeZone)!
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: timeZone)!
        
        if calendar.isDate(dateInterval.end, inSameDayAs: dateInterval.start) {
            return "\(dateInterval.start.formatted(onlyTimeFormatStyle)) - \(dateInterval.end.formatted(onlyTimeFormatStyle))"
        } else {
            var formatStyle1 = Date.FormatStyle().month(.abbreviated).day()
            formatStyle1.timeZone = TimeZone(identifier: timeZone)!
            var formatStyle2 = Date.FormatStyle().hour().minute()
            formatStyle2.timeZone = TimeZone(identifier: timeZone)!
            let formattedDay = dateInterval.end.formatted(formatStyle1)
            let formattedTime = dateInterval.end.formatted(formatStyle2)
            return "\(dateInterval.start.formatted(onlyTimeFormatStyle)) - \(formattedDay) \(formattedTime)"
        }
    }
}
