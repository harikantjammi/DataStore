//
//  PanchangResponseDTO.swift
//  PocketPanchangApp
//
//  Created by Harikant Jammi on 25/03/25.
//
import Foundation

nonisolated public struct PanchangResponseDTO: Codable, Sendable {
    public let data: JSONData
    
    public struct JSONData: Codable, Sendable {
        public let data: Data
        public struct Data: Codable, Sendable {
            public let nakshatra: [Nakshatra]
            public let tithi: [Tithi]
            public let karana: [Karana]
            public let yoga: [Yoga]
            public let vaara: String
            
            public struct Lord: Codable, Sendable {
                public let name: String
                public let id: Int
                public let vedic_name: String
            }
            
            public struct Nakshatra: Codable, Sendable {
                public let id: Int
                public let name: String
                public let lord: Lord
                
                public let start: Date
                public let end: Date
            }
            
            public struct Tithi : Codable, Sendable {
                public let id: Int
                public let name: String
                public let index: Int
                public let paksha: String
                public let start: Date
                public let end: Date
            }
            
            public struct Karana : Codable, Sendable {
                public let id: Int
                public let name: String
                public let start: Date
                public let end: Date
                public let index: Int
            }
            
            public struct Yoga : Codable, Sendable {
                public let id: Int
                public let name: String
                public let start: Date
                public let end: Date
            }
        }
    }
}
