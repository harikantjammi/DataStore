//
//  ChoghadiyaTableListModel.swift
//  PocketPanchangApp
//
//  Created by Harikant Jammi on 04/05/25.
//

import SwiftUI
import Foundation

public struct ChoghadiyaTableListModel {
    public let sections: [Section]
    
    public struct Section: Identifiable {
        public let id = UUID()
        public let title: String
        public let rows: [Row]
        
        public struct Row: Identifiable {
            public let id = UUID()
            public let titleFill: Color
            public let title: String
            public let titleAccessoryText: String?
            public let subTitle: String
        }
    }
}

extension ChoghadiyaTableListModel {
    public init(dto: ChoghadiyaDTO, tz: String) {
        var sections: [Section] = []
        if let activeChoghadiya = dto.data.data.muhurat.first(where: {$0.isActive}) {
            sections.append(Section(title: "Current Choghadiya",
                                    rows: [.init(muhurat: activeChoghadiya, tz: tz)]))
        }
        let dayChoghadiyas = dto.data.data.muhurat.filter { $0.is_day }
        let nightChoghadiyas = dto.data.data.muhurat.filter { !$0.is_day }
        if !dayChoghadiyas.isEmpty {
            sections.append(Section(title: "Day Choghadiya",
                                    rows: dayChoghadiyas.map { .init(muhurat: $0, tz: tz) } ))
        }
        if !nightChoghadiyas.isEmpty {
                sections.append(Section(title: "Night Choghadiya",
                                        rows: nightChoghadiyas.map { .init(muhurat: $0, tz: tz) }))
        }
        self.sections = sections
    }
}

public extension ChoghadiyaTableListModel.Section.Row {
    init(muhurat: ChoghadiyaDTO.Data.Data.Muhurat, tz: String) {
        self.title = muhurat.name
        if let vela = muhurat.vela {
            self.titleAccessoryText = "(" + vela + ")"
        } else {
            self.titleAccessoryText = nil
        }
        self.titleFill = muhurat.type.fillColor
        var format = Date.FormatStyle().hour(.twoDigits(amPM: .abbreviated)).minute(.twoDigits)
        format.timeZone = TimeZone(identifier: tz)!
        
        let formattedStartDate = muhurat.start.formatted(format)
        let formattedEndDate = muhurat.end.formatted(format)
        subTitle = "\(formattedStartDate) - \(formattedEndDate)"
    }
}

public extension ChoghadiyaDTO.Data.Data.Muhurat.MuhuratType {
    var fillColor: Color {
        switch self {
        case .inauspicious:
            return .red
        case .auspicious:
            return .green
        case .good:
            return .blue
        }
    }
}

public extension ChoghadiyaDTO.Data.Data.Muhurat {
    var isActive: Bool {
        DateInterval(start: self.start, end: self.end).contains(Date())
    }
}
