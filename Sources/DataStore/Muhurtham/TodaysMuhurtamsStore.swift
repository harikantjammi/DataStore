//
//  TodaysMuhurtamsStore.swift
//  PocketPanchangApp
//
//  Created by Harikant Jammi on 28/03/25.
//

import Foundation

public class TodaysMuhurthamsStore {
    
    public init() {}
    
    @MainActor
    public func getAllMuhurthams(selectedCity: CitySelection,
                             date: Date,
                                 userPreferences: UserPreferences = UserPreferences.shared) async throws -> [MuhurthamsDTO.Data.Data.Muhurthams] {

        let inauspisciousMuhurthamsDTO = try await getMuhurthams(type: .inauspicious,
                                                                 selectedCity: selectedCity,
                                                                 date: date,
                                                                 userPreferences: userPreferences)
        let auspiciousMuhurthamsDTO = try await getMuhurthams(type: .auspicious,
                                                              selectedCity: selectedCity,
                                                              date: date,
                                                              userPreferences: userPreferences)
        let allMuhurthams = inauspisciousMuhurthamsDTO.data.data.muhurat + auspiciousMuhurthamsDTO.data.data.muhurat
    
        let allMuhurthamsSorted = allMuhurthams.sorted(by: { $0.period.first?.start ?? Date.distantPast < $1.period.first?.start ?? Date.distantPast })
        return allMuhurthamsSorted
    }
    
    private enum MuhurthamsAPIPath :String {
        case auspicious = "/get-auspicious-period"
        case inauspicious = "/get-inauspicious-period"
    }
    
    
    @MainActor
    private func getMuhurthams(type: MuhurthamsAPIPath,
                               selectedCity: CitySelection,
                               date: Date,
                               userPreferences: UserPreferences) async throws -> MuhurthamsDTO {
        let appwrite = Appwrite.shared
        let queryItems = PanchangAPIQueryItemsBuilder()
            .setAyanamsa(userPreferences.currentAyanamsa)
            .setDate(date, tz: selectedCity.tz)
            .set(latitude: selectedCity.latitude,
                 longitude: selectedCity.longitude)
            .build()
        return try await appwrite.executeFunction("6788e8bf000f944e2335",
                                                  path: type.rawValue,
                                                  queryItems: queryItems)
    }
    
}
