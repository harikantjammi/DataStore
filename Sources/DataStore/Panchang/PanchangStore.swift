//
//  Panchangstore.swift
//  PocketPanchangApp
//
//  Created by Harikant Jammi on 25/03/25.
//
import Foundation
import DataStore

class PanchangStore {
    let appWrite = Appwrite.shared
    
    func getPanchang(selectedCity: CitySelection,
                     date: Date,
                     userPreferences: UserPreferences) async throws -> PanchangResponseDTO {
        let tz = selectedCity.tz
        let longitude = selectedCity.longitude
        let latitude = selectedCity.latitude
        let path = "/get-panchang"
        let ayanmasa = userPreferences.currentAyanamsa
        let queryItems = PanchangAPIQueryItemsBuilder()
            .setAyanamsa(ayanmasa)
            .set(latitude: latitude, longitude: longitude)
            .setDate(date, tz: tz)
            .build()
        
        return try await appWrite.executeFunction("6788e8bf000f944e2335", path: path, queryItems: queryItems)
        
    }
    
}
                                           

