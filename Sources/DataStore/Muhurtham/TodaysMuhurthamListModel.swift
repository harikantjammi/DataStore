//
//  TodaysMuhurthamListModel.swift
//  PocketPanchangApp
//
//  Created by Harikant Jammi on 27/03/25.
//

import SwiftUI

public struct TodaysMuhurthamListModel {
    public  let rows: [Row]
    
    public struct Row: Identifiable {
        public let title: String
        public let symbol: String
        public let tint: Color
        public let subTitle: String
        public let id = UUID()
        public let dateInterval: DateInterval
        
        public init(title: String, symbol: String, tint: Color, subTitle: String, dateInterval: DateInterval) {
            self.title = title
            self.symbol = symbol
            self.tint = tint
            self.subTitle = subTitle
            self.dateInterval = dateInterval
        }
    }
    
    public init(muhurthams: [TodayStore.ExtendedPanchangModel.PanchangModel.Data.Period],
         timezone: String) {

        rows = muhurthams
                .map { TodaysMuhurthamListModel.Row.build(from: $0,
                                                          timeZone: timezone) }
                .flatMap { $0 }
                .sorted { $0.dateInterval < $1.dateInterval }
    }
}

public extension TodayStore.ExtendedPanchangModel.PanchangModel.Data.Period {
    var isAuspiscious: Bool {
        self.type.lowercased() == "auspicious"
    }
}

public extension TodaysMuhurthamListModel.Row {
    static func build(from muhurthams : TodayStore.ExtendedPanchangModel.PanchangModel.Data.Period,
                      timeZone: String) -> [TodaysMuhurthamListModel.Row] {
        let title = muhurthams.name
        let isAuspiscious = muhurthams.isAuspiscious
        let periods = muhurthams.period
        
        return periods.map { period in
                return Self.init(title: title,
                                 symbol: isAuspiscious ? "circle.fill" : "circle",
                                 tint: isAuspiscious ? Color.green : Color.red,
                                 subTitle: PanchangTimingsListModel.Section.Row.buildValueLabelText(dateInterval: DateInterval(start: period.start,
                                                                                                                               end: period.end),
                                                                                                    timeZone: timeZone),
                                 dateInterval: DateInterval(start: period.start, end: period.end))
            }
        }
    }

