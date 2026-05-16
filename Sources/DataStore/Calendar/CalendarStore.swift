//
//  CalendarStore.swift
//  DataStore
//
//  Created by Harikant Jammi on 07/08/25.
//
import Foundation

@MainActor
public class CalendarStore: Sendable {
    public static let shared = CalendarStore()
    
    public enum CalendarStoreError: Error {
        case noData
    }
    
    
    public enum Model {
        public struct CalendarDayComponents: Identifiable, Sendable {
            public let day: Int
            public let month: Int
            public let year: Int
            public let id = UUID()
            
            public let nakshatra: String
            public let chandra_rasi: String
            public let festival: String?
            
            public let formattedDate: String
            public let sk_pk: String?
            public let sk_pk_name: String?
            public let month_name_hindu: String?
            
            public init(day: Int,
                        month: Int,
                        year: Int,
                        nakshatra: String,
                        chandra_rasi: String,
                        festival: String?,
                        formattedDate: String,
                        sk_pk: String?,
                        sk_pk_name: String?,
                        month_name_hindu: String?) {
                self.day = day
                self.month = month
                self.year = year
                self.nakshatra = nakshatra
                self.chandra_rasi = chandra_rasi
                self.festival = festival
                self.formattedDate = formattedDate
                self.sk_pk = sk_pk
                self.sk_pk_name = sk_pk_name
                self.month_name_hindu = month_name_hindu
            }
        }
    }
    
    public func getUpcomingCalendar(date: Date, tz: String) async throws -> [Model.CalendarDayComponents] {
        let date = Self.getFormattedDate(date: date, tz: tz)
        let response: [CalendarStore.Response.DTO] = try await Appwrite.shared.executeFunction("67b91e390034cf42f28e",
                                                                                               path: "/calendar/days",
                                                                                               queryItems: [
                                                                                                URLQueryItem(name: "limit", value: "3"),
                                                                                                URLQueryItem(name: "start", value: date)
                                                                                               ])
        return response.map { .init(dto: $0, formattedDate: "") }
    }
    
    public static func getFormattedDate(date: Date, tz: String) -> String {
        let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(identifier: tz)
            return formatter
        }()
        return dateFormatter.string(from: date)
    }
    
    
    
    public struct Response: Codable, Sendable {
        public let response: [DTO]
        public struct DTO: Codable, Sendable {
            public let day: Int
            public let month: Int
            public let year: Int
            public let nakshatra: String
            public let chandra_rasi: String
            public let festival: String?
            public let sk_pk: String?
            public let sk_pk_name: String?
            public let month_name_hindu: String?
        }
    }
    
    private func getCalendar(date: String, tz: String) async throws -> Response {
        let response: Response = try await Appwrite.shared.executeFunction("67b91e390034cf42f28e",
                                                                           path: "/calendar/days/\(date)")
        return response
    }
    
    private func getFormattedCalendarDate(formattedDate: String, userPreferences: UserPreferences) async throws -> String {
        struct CalendarDateComponentsResponse: Codable {
            //let status: String
            let data: Data
            
            struct Data: Codable {
                let data: Data
                
                struct Data: Codable {
                    let calendarDate: CalendarDate
                    
                    enum CodingKeys: String, CodingKey {
                        case calendarDate = "calendar_date"
                    }
                    
                    struct CalendarDate: Codable {
                        let name: String
                        let year: Int
                        let month: Int
                        let day: Int
                        let yearName: String
                        let monthName: String
                        
                        enum CodingKeys: String, CodingKey {
                            case name, year, month, day
                            case yearName = "year_name"
                            case monthName = "month_name"
                        }
                        
                        var formattedDate: String {
                            return "\(monthName) \(day), \(year) \(name) (\(yearName))"
                        }
                    }
                }
            }
            
            
        }
        
        let calendar = userPreferences.currentCalendar
        let response: CalendarDateComponentsResponse  = try await Appwrite.shared.executeFunction("6788e8bf000f944e2335",
                                                                                                  path: "/get-calendar",
                                                                                                  queryItems: [
                                                                                                    URLQueryItem(name: "la", value: "en"),
                                                                                                    URLQueryItem(name: "calendar", value: calendar.rawValue),
                                                                                                    URLQueryItem(name: "date", value: formattedDate)
                                                                                                  ])
        return response.data.data.calendarDate.formattedDate
        
    }
}

extension CalendarStore.Model.CalendarDayComponents {
    init(dto: CalendarStore.Response.DTO,
         formattedDate: String) {
        self.day = dto.day
        self.month = dto.month
        self.year = dto.year
        self.chandra_rasi = dto.chandra_rasi
        self.festival = dto.festival
        self.nakshatra = dto.nakshatra
        self.formattedDate = formattedDate
        self.month_name_hindu = dto.month_name_hindu
        self.sk_pk = dto.sk_pk
        self.sk_pk_name = dto.sk_pk_name
    }
}

