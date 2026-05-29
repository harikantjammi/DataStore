//
//  AppReverseGeoCoder.swift
//  DataStore
//
//  Created by Harikant Jammi on 29/05/26.
//

import CoreLocation

public class AppReverseGeoCoder {
    public init() {}
    private var geocoder = CLGeocoder()
    
    public struct Response: Codable {
        public let data: CitySearchResult
    }
    
    
    
    public func reverseGeocode(location: CLLocation) async throws -> CitySearchResult {
        let response: Response = try await Appwrite.shared.executeFunction("6788e8bf000f944e2335",
                                                                           path: "/reversegeocode",
                                                                           queryItems: [
                                                                            URLQueryItem(name: "lat",
                                                                                         value: "\(location.coordinate.latitude)"),
                                                                            URLQueryItem(name: "lon",
                                                                                         value: "\(location.coordinate.longitude)")
                                                                           ])
        
        return response.data
    }
}
