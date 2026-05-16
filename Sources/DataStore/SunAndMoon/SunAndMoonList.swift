//
//  File.swift
//  DataStore
//
//  Created by Harikant Jammi on 27/07/25.
//

import Foundation
import SwiftUI

public struct SunAndMoonList {
    public let sections: [Section]
    
    public struct Section: Identifiable {
        public let id: UUID = UUID()
        public let title: String
        public let rows: [Row]
        
        public struct Row: Identifiable {
            public let id = UUID()
            public let symbol: String
            public let tint: Color
            public let title: String
            public let subTitle: String
            public let showDivider: Bool
            
            public init(symbol: String, tint: Color, title: String, subTitle: String, showDivider: Bool) {
                self.symbol = symbol
                self.tint = tint
                self.title = title
                self.subTitle = subTitle
                self.showDivider = showDivider
            }
        }
        
        public init(title: String, rows: [Row]) {
            self.title = title
            self.rows = rows
        }
    }
    
    public init(sections: [Section]) {
        self.sections = sections
    }
    
    public init (dto: SunAndMoonDetailsStore.DTO,
                 tz: String) {
        var f = Date.FormatStyle()
            .hour(.twoDigits(amPM: .abbreviated))
            .minute(.twoDigits)
        f.timeZone = TimeZone(identifier: tz)!
        
        sections = [
            Section(title: "Sun & Moon",
                    rows: [.init(symbol: "sunrise.fill",
                                 tint: Color.orange,
                                 title: "SUNRISE",
                                 subTitle: dto.astronomy.astro.sunrise.formatted(f),
                                 showDivider: true),
                           .init(symbol: "sunset.fill",
                                 tint: Color.purple,
                                 title: "SUNSET",
                                 subTitle: dto.astronomy.astro.sunset.formatted(f),
                                 showDivider: true),
                            .init(symbol: "moonrise.fill",
                                  tint: Color.blue,
                                  title: "MOONRISE",
                                  subTitle: dto.astronomy.astro.moonrise.flatMap { $0.formatted(f) } ?? "",
                                  showDivider: true),
                            .init(symbol: "moonset.fill",
                                  tint: Color.blue,
                                  title: "MOONSET",
                                  subTitle: dto.astronomy.astro.moonset.flatMap { $0.formatted(f) } ?? "",
                                  showDivider: true),
                            .init(symbol: dto.astronomy.astro.moon_phase.sfSymbol,
                                  tint: Color.blue,
                                  title: "MOON PHASE",
                                  subTitle: dto.astronomy.astro.moon_phase.rawValue,
                                  showDivider: false)
                    ])
        ]
    }
}
