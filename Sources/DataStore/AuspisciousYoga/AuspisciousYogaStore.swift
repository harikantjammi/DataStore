//
//  File.swift
//  DataStore
//
//  Created by Harikant Jammi on 29/05/26.
//

import Foundation

public struct AuspiciousYogaDTO: Codable {
    public let data: Data
    
    public struct Data: Codable {
        public let status: String
        public let data: Data
        
        public struct Data: Codable {
            public let auspicious_yoga: [AuspiciousYoga]
            
            public struct AuspiciousYoga: Codable {
                public let id: Int
                public let name: String
                public let period: [Period]
                
                public struct Period: Codable {
                    public let start: Date
                    public let end: Date
                    public let combination: [Combination]
                    
                    public struct Combination: Codable {
                        public let type: String
                        public let name: String
                    }
                }
            }
        }
    }
}

public class AuspisciousYogaStore {
    public init() {}
    public func fetchAuspisciousYoga(tz: String, latitude: Double, longitude: Double,
                              userPreferences: UserPreferences? = nil,
                              date: Date) async throws -> AuspiciousYogaDTO {
        let prefs = userPreferences ?? UserPreferences.shared
        let appwrite = Appwrite.shared
        let query = PanchangAPIQueryItemsBuilder()
            .set(latitude: latitude,
                 longitude: longitude)
            .setAyanamsa(prefs.currentAyanamsa)
            .setDate(date, tz: tz)
            .build()
        return try await appwrite.executeFunction("6788e8bf000f944e2335",
                                                  path: "/get-auspicious-yoga",
                                                  queryItems: query)
        
    }
    
}
