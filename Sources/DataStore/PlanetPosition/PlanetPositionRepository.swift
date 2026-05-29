//
//  PlanetPositionRepository.swift
//  DataStore
//
//  Created by Harikant Jammi on 29/05/26.
//


import Foundation

public class PlanetPositionRepository {
    @MainActor
    public func getPlanetPositions(tz: String,
                            latitude: Double,
                            longitude: Double,
                            userPreferences: UserPreferences,
                            date: Date) async throws -> PlanetPositionDTO {
        let appwrite = Appwrite.shared
        let userPreferences = UserPreferences.shared
        let query = PanchangAPIQueryItemsBuilder()
            .set(latitude: latitude, longitude: longitude)
            .setAyanamsa(userPreferences.currentAyanamsa)
            .setDate(date, tz: tz)
            .build()
        
        return try await appwrite.executeFunction("6788e8bf000f944e2335",
                                                  path: "/get-planet-position",
                                                  queryItems: query)
    }
}
