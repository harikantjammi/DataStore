//
//  SunAndMoonDetailsStore.swift
//  PocketPanchangApp
//
//  Created by Harikant Jammi on 19/03/25.
//

import Foundation
import DataStore

class SunAndMoonDetailsStore {
    
    struct DTO: Codable {
        enum MoonPhase: String, Codable, CaseIterable {
            case newMoon = "New Moon"
            case waxingCrescent = "Waxing Crescent"
            case firstQuarter = "First Quarter"
            case waxingGibbous = "Waxing Gibbous"
            case fullMoon = "Full Moon"
            case waningGibbous = "Waning Gibbous"
            case lastQuarter = "Last Quarter"
            case waningCrescent = "Waning Crescent"
            
            var sfSymbol: String {
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
        let astronomy: Astronomy
        struct Astronomy: Codable {
            let astro: Astro
            struct Astro: Codable {
                let sunrise: Date
                let sunset: Date
                let moonrise: Date?
                let moonset: Date?
                let moon_phase: MoonPhase
            }
        }
    }
    
    func fetchSunAndMoonDetails(selectedCity: CitySelection, date: Date) async throws -> DTO {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: selectedCity.tz)
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let formattedDateParam = URLQueryItem(name: "date", value: dateFormatter.string(from: date))
        let cityParam = URLQueryItem(name: "city", value: "\(selectedCity.name) \(selectedCity.state)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))
        let appwrite = Appwrite.shared
        let response: DTO = try await appwrite.executeFunction("6781b317002a58e5064b",
                                 path: "/astronomy", queryItems: [cityParam, formattedDateParam])
        return response
        
    }
}

extension SunAndMoonDetailsStore.DTO.MoonPhase {
    var emoji: String {
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
