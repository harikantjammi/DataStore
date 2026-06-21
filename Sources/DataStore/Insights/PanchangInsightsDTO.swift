//
//  PanchangInsightsDTO.swift
//  DataStore
//
//  Created by Harikant Jammi on 21/06/26.
//
import Foundation

public struct PanchangInsightsResponse: Codable {
    public let tithi: PanchangComponent
    public let vaara: PanchangComponent
    public let nakshatra: PanchangComponent
    public let yoga: PanchangComponent
    public let karana: PanchangComponent
}

public struct PanchangComponent: Codable {
    public let information: String
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
