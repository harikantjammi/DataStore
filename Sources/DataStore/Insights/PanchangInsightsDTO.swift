//
//  PanchangInsightsDTO.swift
//  DataStore
//
//  Created by Harikant Jammi on 21/06/26.
//
import Foundation

public struct PanchangInsightsResponse: Codable {
    public let panchang: PanchangTimings
    public let recommendations: ComponentRecommendations
}

public struct PanchangTimings: Codable {
    public let vaara: String
    public let tithi: [TithiTiming]
    public let nakshatra: [NakshatraTiming]
    public let yoga: [PanchangTiming]
    public let karana: [PanchangTiming]
}

public struct PanchangTiming: Codable {
    public let name: String
    public let start: Date
    public let end: Date
}

public struct TithiTiming: Codable {
    public let name: String
    public let paksha: String
    public let start: Date
    public let end: Date
}

public struct NakshatraTiming: Codable {
    public let name: String
    public let lord: NakshatraLord
    public let start: Date
    public let end: Date
}

public struct NakshatraLord: Codable {
    public let name: String
    public let vedicName: String

    enum CodingKeys: String, CodingKey {
        case name
        case vedicName = "vedic_name"
    }
}

public struct ComponentRecommendations: Codable {
    public let tithi: PanchangComponent
    public let vaara: PanchangComponent
    public let nakshatra: PanchangComponent
    public let yoga: PanchangComponent
    public let karana: PanchangComponent
}

public struct PanchangComponent: Codable {
    public let summary: String
    public let recommendations: [PanchangRecommendation]
}

public struct PanchangRecommendation: Codable {
    public let text: String
    public let type: RecommendationType

    public enum RecommendationType: String, Codable {
        case `do`
        case avoid
        case warning
        case info
    }
}
