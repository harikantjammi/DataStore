//
//  TimeZoneFetcher.swift
//  DataStore
//
//  Created by Harikant Jammi on 29/05/26.
//

import CoreLocation
@MainActor
public class TimeZoneFetcher {
    public init() {}
    public struct Response: Codable {
        public let data: Data
        public struct Timezone: Codable {
            public let name: String
        }
        public struct Data: Codable {
            public let timezone: Timezone
        }
    }
    
    @MainActor
    public func fetchTimeZone(for location: CLLocation) async throws -> String {
        let response: Response = try await Appwrite.shared.executeFunction("6788e8bf000f944e2335",
                                                                           path: "/timezone",
                                                                           queryItems: [
                                                                            URLQueryItem(name: "lat",
                                                                                         value: "\(location.coordinate.latitude)"),
                                                                            URLQueryItem(name: "lon",
                                                                                         value: "\(location.coordinate.longitude)")
                                                                           ])
        return response.data.timezone.name
    }
    
    @MainActor
    public func fetchTimeZone(for city: City) async throws -> String {
        try await fetchTimeZone(for: city.location)
    }
}
