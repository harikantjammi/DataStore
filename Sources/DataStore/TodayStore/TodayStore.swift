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
        public let dayRecommendations: DayRecommendations?
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
    
    public struct DayRecommendations: Codable, Sendable {
        public let dayRating: DayRating
        public let recommendations: [Recommendation]
        
        public enum DayRating: String, Codable, Sendable {
            case excellent
            case good
            case neutral
            case bad
        }
        
        public enum RecommendationType: String, Codable, Sendable {
            case festival
            case info
            case `do`
            case avoid
            case warning
        }
        
        public struct Recommendation: Codable, Sendable {
            public let type: RecommendationType
            public let text: String
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
        let (astronomy, calendar, panchang) = try await (astronomyData, calendarEvents, extendedPanchangData)

        let recommendations = try await fetchTodaysRecommendations(tz: tz,
                                                                   longitude: longitude,
                                                                   latitude: latitude,
                                                                   date: date,
                                                                   citySelection: city)
        return TodayModel(
            citySelection: city,
            panchang: panchang,
            calendarEvents: calendar,
            sunAndMoonDetails: astronomy,
            dayRecommendations: recommendations)
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
    
    @MainActor
    private func fetchTodaysRecommendations(tz: String,
                                            longitude: Double,
                                            latitude: Double,
                                            date: Date,
                                            citySelection: CitySelection) async throws -> DayRecommendations {
        let appwrite = Appwrite.shared
        let path = "/today-insights"
        let queryItems = TodayInsightsQueryItemsBuilder()
            .setLatitude(latitude)
            .setLongitude(longitude)
            .setDate(date, tz: tz)
            .setCity(citySelection.name)
            .setState(citySelection.state)
            .setTimezone(tz)
            .build()
        
        return try await appwrite.executeFunction("6a0964fa0022397c9c00",
                                                  path: path, queryItems: queryItems)
    }
}

extension TodayStore.TodayModel {
    public var containsAllData: Bool {
        return self.sunAndMoonDetails?.astronomy != nil && !self.calendarEvents.isEmpty && self.panchang != nil
    }
}

class TodayInsightsQueryItemsBuilder {
    private var queryItems: [String: URLQueryItem] = [:]
    
    @discardableResult
    func setCity(_ city: String) -> Self {
        queryItems["city"] = URLQueryItem(name: "city", value: city)
        return self
    }
    
    @discardableResult
    func setLatitude(_ latitude: Double) -> Self {
        queryItems["latitude"] = URLQueryItem(name: "latitude", value: "\(latitude)")
        return self
    }
    
    @discardableResult
    func setLongitude(_ longitude: Double) -> Self {
        queryItems["longitude"] = URLQueryItem(name: "longitude", value: "\(longitude)")
        return self
    }
    
    @discardableResult
    func setState(_ state: String) -> Self {
        queryItems["state"] = URLQueryItem(name: "state", value: state)
        return self
    }
    
    @discardableResult
    func setTimezone(_ timezone: String) -> Self {
        queryItems["tz"] = URLQueryItem(name: "tz", value: timezone)
        return self
    }
    
    @discardableResult
    func setDate(_ date: Date, tz: String) -> Self {
        let timezone = TimeZone(identifier: tz)!
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = timezone
        let dateString = formatter.string(from: date)
        let dateStringSplitByT = dateString.split(separator: "T")
        let dateSplitFirstPart = dateStringSplitByT[0]
            
        let dateSplitSecondPart = dateStringSplitByT[1]
            .replacingOccurrences(of: ":", with: "%3A")
            .replacingOccurrences(of: "+", with: "%2B")
            .replacingOccurrences(of: "-", with: "%2D")
        
        
        
        queryItems["date"] = URLQueryItem(name: "date",
                                              value: dateSplitFirstPart + "T" + dateSplitSecondPart)
        return self
    }
    func build() -> [URLQueryItem] {
        return Array(queryItems.values)
    }
    
}
