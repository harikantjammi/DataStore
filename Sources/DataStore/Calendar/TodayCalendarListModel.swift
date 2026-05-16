//
//  TodayCalendarListModel.swift
//  DataStore
//
//  Created by Harikant Jammi on 08/08/25.
//
import Foundation
import SwiftUI

public struct TodayCalendarListModel {
    public struct Row: Identifiable {
        public let id = UUID()
        public let title: String
        public let subTitle: String
        public let icon: String
        public let showDivider: Bool
        public let tint: Color?
        public let asciiIcon: String
    }
    
    public let title: String
    public let rows: [Row]
    
    public static let defaultCalendar: Calendar = Calendar(identifier: .gregorian)

    public init (calendarEvent: CalendarStore.Model.CalendarDayComponents,
                 tz: String,
                 referenceDate: Date) {
        var format = Date.FormatStyle()
            .weekday(.abbreviated)
            .day(.twoDigits)
            .month(.wide)
            .year(.defaultDigits)
        format.timeZone = TimeZone(identifier: tz)!
        title = Date().formatted(format)
        let todayDetails = calendarEvent
        
        var rows = [
            Row(
                title: "Indian Civil Date",
                subTitle: HinduCalendarDateComponents(calendarDayDetails: todayDetails)?.displayValue ?? "-",
                icon: "calendar",
                showDivider: true,
                tint: Color.teal,
                asciiIcon: "📅"),
            Row(
                title: "Nakshatra",
                subTitle: todayDetails.nakshatra,
                icon: "star",
                showDivider: true,
                tint: .orange,
                asciiIcon: "⭐" ),
            Row(
                title: "Chandra Rasi",
                subTitle: todayDetails.chandra_rasi,
                icon: "moon",
                showDivider: true,
                tint: .blue,
                asciiIcon: "🌙"),
        ]
        if (todayDetails.festival != nil) {
            rows.append(
            Row(
                title: "Festivals",
                subTitle: todayDetails.festival ?? "-",
                icon: "gift",
                showDivider: false,
                tint: Color.blue,
                asciiIcon: "✨"))
        }
        self.rows = rows
    }
    
    static func prepareIndianCalendarFormattedDate(_ date: Date, tz: String) -> String {
        var indianCalendar = Calendar(identifier: .indian)
        indianCalendar.locale = Locale(identifier: "hi_IN")
        indianCalendar.timeZone = TimeZone(identifier: tz)!
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        dateFormatter.calendar = indianCalendar
        return dateFormatter.string(from: date)
    }
}
