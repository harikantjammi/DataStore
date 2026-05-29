//
//  DishaShoolRepository.swift
//  DataStore
//
//  Created by Harikant Jammi on 29/05/26.
//


import Foundation
public class DishaShoolRepository {
    public init() {}
    @MainActor
    public func getDishaShool(tz: String,
                       longitude: Double,
                       latitude: Double,
                       userPreferences: UserPreferences? = nil,
                       date: Date) async throws -> DishaShoolDTO {
        let appwrite = Appwrite.shared
        let preferences = userPreferences ?? UserPreferences.shared
        let query = PanchangAPIQueryItemsBuilder()
            .set(latitude: latitude, longitude: longitude)
            .setAyanamsa(preferences.currentAyanamsa)
            .setDate(date, tz: tz)
            .build()
        
        return try await appwrite.executeFunction("6788e8bf000f944e2335",
                                                  path: "/get-disha-shool",
                                                  queryItems: query)
    }
}
