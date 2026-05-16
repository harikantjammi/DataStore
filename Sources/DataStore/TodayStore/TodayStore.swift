//
//  TodayStore.swift
//  PocketPanchangApp
//
//  Created by Harikant Jammi on 24/05/25.
//

import Foundation

@MainActor
public class TodayStore {
    
    public init() {}
    
    public struct TodayModel {
        public let citySelection: CitySelection
        public let panchang: ExtendedPanchangResponse?
        public let calendarEvents: [CalendarStore.Model.CalendarDayComponents]
        public let sunAndMoonDetails: SunAndMoonDetailsStore.DTO?
    }
    
    public struct ExtendedPanchangResponse: Codable, Sendable {
        public let data: ExtendedPanchangModel
    }
    
    public struct ExtendedPanchangModel: Codable, Sendable {
        public let panchang: PanchangModel
        public let calendar: CalendarModel?
        public struct PanchangModel: Codable, Sendable {
            public let data: Data
            
            public struct Data: Codable, Sendable {
                public let vaara: String
                public let nakshatra: [Nakshatra]
                public let tithi: [Tithi]
                public let karana: [Karana]
                public let yoga: [Yoga]
                public let auspicious_period: [Period]
                public let inauspicious_period: [Period]
                
                public struct Period: Codable, Sendable {
                    public let id: Int
                    public let name: String
                    public let type: String
                    public let period: [Timing]
                    
                    public struct Timing: Codable, Sendable {
                        public let start: Date
                        public let end: Date
                    }
                }
                
                public struct Yoga: Codable, Sendable {
                    public let id: Int
                    public let name: String
                    public let start: Date
                    public let end: Date
                }
                
                public struct Karana: Codable, Sendable {
                    public let index: Int
                    public let id: Int
                    public let name: String
                    public let start: Date
                    public let end: Date
                }
                public struct Tithi: Codable, Sendable {
                    public let id: Int
                    public let index: Int
                    public let name: String
                    public let paksha: String
                    public let start: Date
                    public let end: Date
                }
                
                public struct Nakshatra: Codable, Sendable {
                    public let id: Int
                    public let name: String
                    public let lord: Lord
                    public let start: Date
                    public let end: Date
                    
                    public struct Lord: Codable, Sendable {
                        public let id: Int
                        public let name: String
                        public let vedic_name: String
                    }
                }
            }
        }
        public struct CalendarModel: Codable, Sendable {
            public let data: Data
            
            public struct Data: Codable, Sendable {
                public let calendar_date: CalendarDate
                public struct CalendarDate: Codable, Sendable {
                    public let id: Int
                    public let name: String
                    public let year: Int
                    public let month: Int
                    public let day: Int
                    public let leap: Int
                    public let year_name: String
                    public let month_name: String
                }
            }
        }
    }
    
    @MainActor
    public func getData(city: CitySelection,
                        userPreferences: UserPreferences = UserPreferences.shared,
                 date: Date = Date()) async throws -> TodayModel {
        let tz = city.tz
        let name = city.name
        let state = city.state
        let longitude = city.longitude
        let latitude = city.latitude
        let userPreferences = UserPreferences.shared
        
        async let astronomyData = try fetchAstronomyData(tz: tz,
                                                                name: name,
                                                                state: state,
                                                                date: date)
        async let calendarEvents = try fetchCalendarEvents(tz: tz,
                                                                  cityName:
                                                                    name, date: date)
        async let extendedPanchangData = try fetchTodayExtendedPanchangData(tz: tz,
                                                                                   longitude: longitude,
                                                                                   latitude: latitude,
                                                                             userPreferences: userPreferences,
                                                                                   date: date)
        return TodayModel(
            citySelection: city,
            panchang: try await extendedPanchangData,
            calendarEvents: try await calendarEvents,
            sunAndMoonDetails: try await astronomyData)
    }
    
    @MainActor
    private func fetchAstronomyData(tz: String, name: String, state: String, date: Date) async throws -> SunAndMoonDetailsStore.DTO {
        let store = SunAndMoonDetailsStore()
        return try await store.fetchSunAndMoonDetails(cityTz: tz,
                                                      cityName: name,
                                                      cityState: state,
                                                      date: date)
    }
    
    private func fetchCalendarEvents(tz: String, cityName: String, date: Date) async throws -> [CalendarStore.Model.CalendarDayComponents] {
        let store = CalendarStore.shared
        return try await store.getUpcomingCalendar(date: date,
                                                   tz: tz)
    }
    
    @MainActor
    private func fetchTodayExtendedPanchangData(tz: String,
                                                longitude: Double,
                                                latitude: Double,
                                                userPreferences: UserPreferences,
                                                date: Date) async throws -> ExtendedPanchangResponse {
        let appwrite = Appwrite.shared
        let path = "/today"
        let ayanmasa = userPreferences.currentAyanamsa
        let queryItems = PanchangAPIQueryItemsBuilder()
            .setAyanamsa(ayanmasa)
            .set(latitude: latitude, longitude: longitude)
            .setDate(date, tz: tz)
            .setCalendarDate(date: date,
                             tz: tz)
            .setCalendarType(userPreferences.currentCalendar)
            .build()
        
        return try await appwrite.executeFunction("6788e8bf000f944e2335",
                                                  path: path,
                                                  queryItems: queryItems)
    }
}

extension TodayStore.TodayModel {
    public var containsAllData: Bool {
        return self.sunAndMoonDetails?.astronomy != nil && !self.calendarEvents.isEmpty && self.panchang != nil
    }
}
