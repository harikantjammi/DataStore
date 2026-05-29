//
//  PanchangtimingListModel.swift
//  PocketPanchangApp
//
//  Created by Harikant Jammi on 26/03/25.
//

import SwiftUI
import Foundation

public struct PanchangTimingsListModel {
    public let sections: [Section]
    
    public init(sections: [Section]) {
        self.sections = sections
    }
    
    public struct Section: Identifiable {
        public let id = UUID()
        public let title: String
        public let rows: [Row]
        
        public init(title: String, rows: [Row]) {
            self.title = title
            self.rows = rows
        }
        
        public struct Row: Identifiable, Hashable {
            public let id = UUID()
            public let title: String
            public let value: String
            public let icon: String
            public let iconTint: Color
            
            public init(title: String, value: String, icon: String, iconTint: Color) {
                self.title = title
                self.value = value
                self.icon = icon
                self.iconTint = iconTint
            }
        }
    }
    
    public init(dto: PanchangResponseDTO,
         timeZone: String,
         referenceDate: Date = Date()) {
        let vaaraSection = Section(title: "Vaara",
                                   rows: [Section.Row(title: PanchangVaara(vaara: dto.data.data.vaara)?.displayValue ?? "",
                                                      value: "",
                                                      icon: "",
                                                      iconTint: Color.cyan)])
        let nakshtraSection = Section(title: "Nakshatra",
                                      rows: dto.data.data.nakshatra
                                                            .filter { DateInterval(start: $0.start, end: $0.end).contains(referenceDate)}
                                                            .map { Section.Row(nakshatra: $0, timeZone: timeZone) })
        let tithiSection = Section(title: "Tithi",
                                   rows: dto.data.data.tithi.filter { DateInterval(start: $0.start, end: $0.end).contains(referenceDate)}
                                                            .map { Section.Row(tithi: $0, timeZone: timeZone) })
        let karanaSection = Section(title: "Karana",
                                    rows: dto.data.data.karana
                                                            .filter { DateInterval(start: $0.start, end: $0.end).contains(referenceDate)}
                                                            .map { Section.Row(karana: $0, timeZone: timeZone) })
        let yogaSection = Section(title: "Yoga",
                                  rows: dto.data.data.yoga
            .filter { DateInterval(start: $0.start, end: $0.end).contains(referenceDate)}
            .map { Section.Row(yoga: $0, timeZone: timeZone) })
        self.sections = [vaaraSection,
                         nakshtraSection,
                         tithiSection,
                         karanaSection,
                         yogaSection]
    }
}

public extension PanchangTimingsListModel.Section.Row {
    
    init(nakshatra: PanchangResponseDTO.JSONData.Data.Nakshatra, timeZone: String) {
        self.title = "\(nakshatra.name) (Lord: \(nakshatra.lord.vedic_name))"
        self.iconTint = Color.purple
        let referenceDate = Date()
        let dateInterval = DateInterval(start: nakshatra.start, end: nakshatra.end)
        self.icon = dateInterval.contains(referenceDate) ? "circle.fill" : "circle"
        value = Self.buildValueLabelText(dateInterval: dateInterval, timeZone: timeZone)
    }
    
    init(tithi: PanchangResponseDTO.JSONData.Data.Tithi, timeZone: String) {
        self.title = "\(tithi.name) (\(tithi.paksha))"
        self.iconTint = Color.indigo
        let dateInterval = DateInterval(start: tithi.start, end: tithi.end)
        self.icon = Self.iconName(for: dateInterval)
        value = Self.buildValueLabelText(dateInterval: dateInterval, timeZone: timeZone)
    }
    
    init (yoga: PanchangResponseDTO.JSONData.Data.Yoga, timeZone: String) {
        self.title = yoga.name
        self.iconTint = .orange
        let dateInterval = DateInterval(start: yoga.start, end: yoga.end)
        self.icon = Self.iconName(for: dateInterval)
        value = Self.buildValueLabelText(dateInterval: dateInterval, timeZone: timeZone)
    }
    
    init (karana: PanchangResponseDTO.JSONData.Data.Karana, timeZone: String) {
        self.title = karana.name
        self.iconTint = .teal
        let referenceDate = Date()
        let dateInterval = DateInterval(start: karana.start, end: karana.end)
        self.icon = dateInterval.contains(referenceDate) ? "circle.fill" : "circle"
        value = Self.buildValueLabelText(dateInterval: dateInterval, timeZone: timeZone)
    }
}

public extension PanchangTimingsListModel.Section.Row {
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
    
    static func iconName(for dateInterval: DateInterval) -> String {
        dateInterval.contains(Date()) ? "circle.fill" : "circle"
    }
    
    static func progressForDateInterval(_ dateInterval: DateInterval) -> Double {
        let now = Date()
        
        if now >= dateInterval.end {
            return 1.0
        } else if now <= dateInterval.start {
            return 0.0
        } else {
            let duration = dateInterval.end.timeIntervalSince(dateInterval.start)
            let elapsedTime = now.timeIntervalSince(dateInterval.start)
            return Double(elapsedTime) / duration
        }
    }
}

public enum PanchangVaara: String {
    case monday = "monday"
    case tuesday = "tuesday"
    case wednesday = "wednesday"
    case thursday = "thursday"
    case friday = "friday"
    case saturday = "saturday"
    case sunday = "sunday"
    
    public var displayValue: String {
        switch self {
            case .monday: "Monday (Somvaar)"
            case .tuesday: "Tuesday (Mangalvaar)"
            case .wednesday: "Wednesday (Budhvaar)"
            case .thursday: "Thursday (Guruvaar)"
            case .friday: "Friday (Shukravaar)"
            case .saturday: "Saturday (Shanivaar)"
            case .sunday: "Sunday (Ravivaar)"
        }
    }
}

extension PanchangVaara {
    public init?(vaara: String) {
        self.init(rawValue: vaara.lowercased())
    }
}
