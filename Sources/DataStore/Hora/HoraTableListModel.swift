//
//  HoraTableListModel.swift
//  DataStore
//
//  Created by Harikant Jammi on 12/08/25.
//

import SwiftUI

public struct HoraTableListModel {
    public let sections: [Section]
    
    public struct Section: Identifiable {
        public let id = UUID()
        public let title: String
        public let rows: [Row]
        
        public struct Row: Identifiable {
            public let id = UUID()
            public let title: String
            public let accessoryTitle: String
            public let subTitle: String
            public let isActive: Bool
            public let titleColor: Color
        }
    }
    
    public init(dto: HoraDTO, tz: String) {
        var sections: [Section] = []

        if let activeHora = dto.data.data.hora_timing.first(where: { $0.isActive }) {
            sections.append(Section(
                title: "Active Hora",
                rows: [.init(horaTiming: activeHora, tz: tz)]))
        }
        
        let dayHoras = dto.data.data.hora_timing.filter { $0.isDay }
        let nightHoras = dto.data.data.hora_timing.filter { !$0.isDay }
//
        if !dayHoras.isEmpty {
            sections.append(Section(
                title: "Day Hora Muhurthams",
                rows: dayHoras.map { .init(horaTiming: $0, tz: tz) }
            ))
        }
        
        if !nightHoras.isEmpty {
            sections.append(Section(
                title: "Night Hora Muhurthams",
                rows: nightHoras.map { .init(horaTiming: $0, tz: tz) }
            ))
        }
                
        self.sections = sections
        
    }
}
import Foundation

public extension HoraTableListModel.Section.Row {
    init(horaTiming: HoraDTO.Data.Data.HoraTiming, tz: String) {
        self.title = "\(horaTiming.hora.name)"
        self.accessoryTitle = horaTiming.hora.vedic_name
        let timezone = TimeZone(identifier: tz)!
        var format = Date.FormatStyle().hour(.twoDigits(amPM: .abbreviated)).minute(.twoDigits)
        format.timeZone = timezone
        
        self.isActive = horaTiming.isActive
        self.subTitle = "\(horaTiming.dateInterval.start.formatted(format)) - \(horaTiming.dateInterval.end.formatted(format))"
        switch horaTiming.severityType {
        case .good:
            self.titleColor = .green
        case .bad:
            self.titleColor = .red
        case .neutral:
            self.titleColor = .primary
        }
    }
}
