//
//  TarabalaRepository.swift
//  DataStore
//
//  Created by Harikant Jammi on 29/05/26.
//

import Foundation

public struct TaraBalaDTO: Codable {
    public let data: Data
    
    public struct Data: Codable {
        public let status: String
        public let data: Data
        
        public struct Data: Codable {
            public let tara_bala: [TaraBala]
            
            public struct TaraBala: Codable {
                public let id: Int
                public let name: String
                public let type : String
                public let start: Date
                public let end: Date
                public let nakshatras: [Nakshatra]
                
                public struct Nakshatra: Codable {
                    public let id: Int
                    public let name: String
                    public let lord: Lord
                    
                    public struct Lord: Codable {
                        public let id: Int
                        public let name: String
                        public let vedic_name: String
                    }
                }
            }
        }
        
    }
}



public class TaraBalaRepository {
    @MainActor
    public func fetchTaraBala(tz: String,
                       longitude: Double,
                       latitude: Double,
                      date: Date,
                       userPreferences: UserPreferences? = nil) async throws -> TaraBalaDTO {
        let appwrite = Appwrite.shared
        let preferences = UserPreferences.shared
        let query = PanchangAPIQueryItemsBuilder()
            .set(latitude: latitude,
                 longitude: longitude)
            .setAyanamsa(preferences.currentAyanamsa)
            .setDate(date, tz: tz)
            .build()
        
        return try await appwrite.executeFunction("6788e8bf000f944e2335",
                                                  path: "/get-tara-bala",
                                                  queryItems: query)
    }
}
