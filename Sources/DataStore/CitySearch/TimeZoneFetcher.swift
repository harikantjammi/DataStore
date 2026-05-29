//
//  TimeZoneFetcher.swift
//  DataStore
//
//  Created by Harikant Jammi on 29/05/26.
//

import CoreLocation
class TimeZoneFetcher {
    struct Response: Codable {
        let data: Data
        struct Timezone: Codable {
            let name: String
        }
        struct Data: Codable {
            let timezone: Timezone
        }
    }
    
    func fetchTimeZone(for location: CLLocation) async throws -> String {
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
    
    func fetchTimeZone(for city: City) async throws -> String {
        try await fetchTimeZone(for: city.location)
    }
}
