//
//  HoraStore.swift
//  PocketPanchangApp
//
//  Created by Harikant Jammi on 02/05/25.
//

import Foundation

public class HoraStore {
    
    public init() {
        
    }
    
    public func getHora(tz: String, latitude: Double, longitude: Double, date: Date) async throws -> HoraDTO {
        let appwrite = Appwrite.shared
        let userPreferences = UserPreferences.shared
        print("get-hora called")
        let query = PanchangAPIQueryItemsBuilder()
            .set(latitude: latitude, longitude: longitude)
            .setAyanamsa(userPreferences.currentAyanamsa)
            .setDate(date, tz: tz)
            .build()
        
        return try await appwrite.executeFunction("6788e8bf000f944e2335",
                                                  path: "/get-hora",
                                                  queryItems: query)
    }
    
    public func getHora(citySelection: CitySelection, date: Date = Date()) async throws -> HoraDTO {
        try await getHora(tz: citySelection.tz,
                          latitude: citySelection.latitude,
                          longitude: citySelection.longitude,
                          date: date)
    }
}
