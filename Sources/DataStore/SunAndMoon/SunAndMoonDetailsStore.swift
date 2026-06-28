//
//  SunAndMoonDetailsStore.swift
//  PocketPanchangApp
//
//  Created by Harikant Jammi on 19/03/25.
//

import Foundation

public class SunAndMoonDetailsStore {
    
    public struct DTO: Codable, Sendable {
        public enum MoonPhase: String, Codable, CaseIterable, Sendable {
            case newMoon = "New Moon"
            case waxingCrescent = "Waxing Crescent"
            case firstQuarter = "First Quarter"
            case waxingGibbous = "Waxing Gibbous"
            case fullMoon = "Full Moon"
            case waningGibbous = "Waning Gibbous"
            case lastQuarter = "Last Quarter"
            case waningCrescent = "Waning Crescent"
            
            public var sfSymbol: String {
                switch self {
                case .newMoon:
                     return "moonphase.new.moon"
                case .firstQuarter:
                     return "moonphase.first.quarter"
                case .fullMoon:
                     return "moonphase.full.moon"
                case .waningGibbous:
                    return "moonphase.waning.gibbous"
                case .lastQuarter:
                    return "moonphase.last.quarter"
                case .waxingGibbous:
                    return "moonphase.waxing.gibbous"
                case .waningCrescent:
                    return "moonphase.waning.crescent"
                case .waxingCrescent:
                    return "moonphase.waxing.crescent"
                }
            }
        }
        public let astronomy: Astronomy
        public struct Astronomy: Codable, Sendable {
            public let astro: Astro
            public struct Astro: Codable, Sendable {
                public let sunrise: Date
                public let sunset: Date
                public let moonrise: Date?
                public let moonset: Date?
                public let moon_phase: MoonPhase
            }
        }
    }
    public init() {}
    
    public func fetchSunAndMoonDetails(cityTz: String,
                                       cityName: String,
                                       cityState: String,
                                       date: Date) async throws -> DTO {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: cityTz)
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let formattedDateParam = URLQueryItem(name: "date", value: dateFormatter.string(from: date))
        let cityParam = URLQueryItem(name: "city", value: "\(cityName) \(cityState)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))
        let appwrite = Appwrite.shared
        let response: DTO = try await appwrite.executeFunction("6781b317002a58e5064b",
                                 path: "/astronomy", queryItems: [cityParam, formattedDateParam])
        return response
        
    }
}

extension SunAndMoonDetailsStore.DTO.MoonPhase {
    public var emoji: String {
        switch self {
        case .newMoon:
            return "🌑"
        case .waxingCrescent:
            return "🌒"
        case .firstQuarter:
            return "🌓"
        case .waxingGibbous:
            return "🌔"
        case .fullMoon:
            return "🌕"
        case .waningGibbous:
            return "🌖"
        case .lastQuarter:
            return "🌗"
        case .waningCrescent:
            return "🌘"
        }
    }
}
