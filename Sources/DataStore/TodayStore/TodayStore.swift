//
//  TodayStore.swift
//  PocketPanchangApp
//
//  Created by Harikant Jammi on 24/05/25.
//

import Foundation
import DataStore

class TodayStore {
    
    struct TodayModel {
        let citySelection: CitySelection
        let panchang: ExtendedPanchangResponse?
        let calendarEvents: [CalendarStore.Model.CalendarDayComponents]
        let sunAndMoonDetails: SunAndMoonDetailsStore.DTO?
    }
    
    struct ExtendedPanchangResponse: Codable {
        let data: ExtendedPanchangModel
    }
    
    struct ExtendedPanchangModel: Codable {
        let panchang: PanchangModel
        let calendar: CalendarModel?
        struct PanchangModel: Codable {
            let data: Data
            
            struct Data: Codable {
                let vaara: String
                let nakshatra: [Nakshatra]
                let tithi: [Tithi]
                let karana: [Karana]
                let yoga: [Yoga]
                let auspicious_period: [Period]
                let inauspicious_period: [Period]
                
                struct Period: Codable {
                    let id: Int
                    let name: String
                    let type: String
                    let period: [Timing]
                    
                    struct Timing: Codable {
                        let start: Date
                        let end: Date
                    }
                }
                
                struct Yoga: Codable {
                    let id: Int
                    let name: String
                    let start: Date
                    let end: Date
                }
                
                struct Karana: Codable {
                    let index: Int
                    let id: Int
                    let name: String
                    let start: Date
                    let end: Date
                }
                struct Tithi: Codable {
                    let id: Int
                    let index: Int
                    let name: String
                    let paksha: String
                    let start: Date
                    let end: Date
                }
                
                struct Nakshatra: Codable {
                    let id: Int
                    let name: String
                    let lord: Lord
                    let start: Date
                    let end: Date
                    
                    struct Lord: Codable {
                        let id: Int
                        let name: String
                        let vedic_name: String
                    }
                }
            }
        }
        struct CalendarModel: Codable {
            let data: Data
            
            struct Data: Codable {
                let calendar_date: CalendarDate
                struct CalendarDate: Codable {
                    let id: Int
                    let name: String
                    let year: Int
                    let month: Int
                    let day: Int
                    let leap: Int
                    let year_name: String
                    let month_name: String
                }
            }
        }
    }
    
    @MainActor
    func getData(city: CitySelection,
                 userPreferences: UserPreferences = UserPreferences(),
                 date: Date = Date()) async throws -> TodayModel {
        let tz = city.tz
        let name = city.name
        let state = city.state
        let longitude = city.longitude
        let latitude = city.latitude
        async let astronomyData = try? await fetchAstronomyData(tz: tz,
                                                                name: name,
                                                                state: state,
                                                                date: date)
        async let calendarEvents = try? await fetchCalendarEvents(tz: tz,
                                                                  cityName:
                                                                    name, date: date)
        async let extendedPanchangData = try? await fetchTodayExtendedPanchangData(tz: tz,
                                                                                   longitude: longitude,
                                                                                   latitude: latitude,
                                                                                  userPreferences: UserPreferences(),
                                                                                   date: date)
        return await TodayModel(
            citySelection: city,
            panchang: extendedPanchangData,
            calendarEvents: calendarEvents ?? [],
            sunAndMoonDetails: astronomyData)
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
        let store = await CalendarStore.shared
        return try await store.getUpcomingCalendar(date: date,
                                                   tz: tz)
    }
    
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
