//
//  ChoghadiyaRepository.swift
//  PocketPanchangApp
//
//  Created by Harikant Jammi on 04/05/25.
//

import Foundation
public class ChoghadiyaRepository {
    
    public init() {}
    
    public func fetchChoghadiya(tz: String,
                         latitude: Double,
                         longitude: Double,
                                userPreferences: UserPreferences = UserPreferences.shared,
                         date: Date) async throws -> ChoghadiyaDTO {
        let appwrite = Appwrite.shared
        print("get-choghadiya called")
        let query = PanchangAPIQueryItemsBuilder()
            .set(latitude: latitude, longitude: longitude)
            .setAyanamsa(userPreferences.currentAyanamsa)
            .setDate(date, tz: tz)
            .build()
        
        return try await appwrite.executeFunction("6788e8bf000f944e2335",
                                                  path: "/get-choghadiya",
                                                  queryItems: query)
    }
}
