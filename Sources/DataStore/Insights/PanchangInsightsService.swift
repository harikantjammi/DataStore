//
//  File.swift
//  DataStore
//
//  Created by Harikant Jammi on 21/06/26.
//

import Foundation

public class PanchangInsightsService {
    public init () {}
    
    public func getPanchangInsights(date: Date, citySelection: CitySelection) async throws -> PanchangInsightsResponse {
        let appWrite = Appwrite.shared
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: citySelection.tz)
        let dateString = dateFormatter.string(from: date)
        return try await appWrite.executeFunction("6a0964fa0022397c9c00",
                                                  path: "/panchang-insights",
                                                  queryItems: [
                                                    URLQueryItem(name: "longitude", value: "\(citySelection.longitude)"),
                                                    URLQueryItem(name: "latitude", value: "\(citySelection.latitude)"),
                                                    URLQueryItem(name: "date", value: dateString)
                                                  ])
    }
}
