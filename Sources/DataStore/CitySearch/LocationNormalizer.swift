//
//  LocationNormalizer.swift
//  DataStore
//
//  Created by Harikant Jammi on 29/05/26.
//

import CoreLocation
class LocationNormalizer {
    public init() {}
    func normalize(_ location: CLLocation) async throws -> CLLocation {

        struct Response: Codable {
            let latitude: Double
            let longitude: Double
        }
        
        let response: Response = try await Appwrite.shared.executeFunction("6788e8bf000f944e2335",
                                                                             path: "/normalizelocation",
                                                                             queryItems:
                                                                                [URLQueryItem(
                                                                                    name: "coordinates",
                                                                                    value: "\(location.coordinate.latitude),\(location.coordinate.longitude)")])
        return CLLocation(latitude: response.latitude,
                          longitude: response.longitude)
    }
}
