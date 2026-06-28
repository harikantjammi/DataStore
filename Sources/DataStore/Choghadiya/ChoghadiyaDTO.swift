//
//  ChoghadiyaDTO.swift
//  PocketPanchangApp
//
//  Created by Harikant Jammi on 04/05/25.
//

import Foundation

public struct ChoghadiyaDTO: Codable, Sendable {
    public let data: Data
    
    public struct Data: Codable, Sendable {
        public let status: String
        public let data: Data
        
        public struct Data: Codable, Sendable {
            public let muhurat: [Muhurat]
            
            public struct Muhurat: Codable, Sendable {
                public let id: Int
                public let name: String
                public let type: MuhuratType
                public let vela: String?
                public let is_day: Bool
                public let start: Date
                public let end: Date
                
                public enum MuhuratType: String, Codable, Sendable {
                    case inauspicious = "Inauspicious"
                    case auspicious = "Most Auspicious"
                    case good = "Good"
                }
            }
        }
    }
}
