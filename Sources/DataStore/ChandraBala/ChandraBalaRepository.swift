//
//  ChandraBalaRepository.swift
//  DataStore
//
//  Created by Harikant Jammi on 29/05/26.
//


import Foundation

public class ChandraBalaRepository {
    @MainActor
    public func fetchChandraBala(tz: String,
                          latitude: Double,
                          longitude: Double,
                          date: Date,
                          userPreferences: UserPreferences? = nil) async throws -> ChandraBalaDTO {
        let appwrite = Appwrite.shared
        let preferences = userPreferences ?? UserPreferences.shared
        let query = PanchangAPIQueryItemsBuilder()
            .set(latitude: latitude, longitude: longitude)
            .setAyanamsa(preferences.currentAyanamsa)
            .setDate(date, tz: tz)
            .build()
        
        return try await appwrite.executeFunction("6788e8bf000f944e2335",
                                                  path: "/get-chandra-bala",
                                                  queryItems: query)
    }
}
