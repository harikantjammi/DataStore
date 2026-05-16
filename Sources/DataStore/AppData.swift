//
//  AppData.swift
//  DataStore
//
//  Created by Harikant Jammi on 26/07/25.
//

import Foundation
import SwiftData

public enum AppDataSchemaV1: VersionedSchema {
    public static let versionIdentifier = Schema.Version(1, 0, 0)
    public static var models: [any PersistentModel.Type] {
        [CitySelection.self, CalendarEntryCollection.self, CalendarEntry.self]
    }
}


//extension Schema.Version: @unchecked @retroactive Sendable {}

@Model
public class CitySelection {
    @Attribute(.unique)
    public var id: String
    public var name: String
    public var lastSelectedDate: Double
    public var country: String
    public var latitude: Double
    public var longitude: Double
    public var state: String
    public var tz: String
    
    public init(id: String,
         name: String,
         lastSelectedDate: Date,
         country: String,
         latitude: Double,
         longitude: Double,
         state: String,
         tz: String) {
        self.name = name
        self.lastSelectedDate = lastSelectedDate.timeIntervalSince1970
        self.country = country
        self.latitude = latitude
        self.longitude = longitude
        self.id = id
        self.state = state
        self.tz = tz
    }
}


@Model
public class CalendarEntryCollection {
    public var month: Int
    public var year: Int
    @Relationship(deleteRule: .cascade)
    public var entries: [CalendarEntry] = []
    public var lastUpdated: Date
    
    public init(month: Int, year: Int, entries: [CalendarEntry] = []) {
        self.month = month
        self.year = year
        self.entries = entries
        self.lastUpdated = Date()
    }
}

@Model
public class CalendarEntry {
    public var day: Int
    public var month: Int
    public var year: Int
    public var nakshatra: String
    public var chandra_rasi: String
    public var festival: String?
    public var sk_pk: String?
    public var sk_pk_name: String?
    public var month_name_hindu: String?
    
    public init(day: Int,
         month: Int,
         year: Int,
         nakshatra: String,
         chandra_rasi: String,
         festival: String? = nil,
         sk_pk: String?,
         sk_pk_name: String?,
         month_name_hindu: String?) {
        self.day = day
        self.month = month
        self.year = year
        self.nakshatra = nakshatra
        self.chandra_rasi = chandra_rasi
        self.festival = festival
        self.sk_pk = sk_pk
        self.sk_pk_name = sk_pk_name
        self.month_name_hindu = month_name_hindu
    }
}
