//
//  PlanetPositionDTO.swift
//  DataStore
//
//  Created by Harikant Jammi on 29/05/26.
//
import Foundation

public struct PlanetPositionDTO: Codable {
    public let data: Data
    public struct Data: Codable {
        public let status: String
        public let data: Data
        
        public struct Data: Codable {
            public let planet_position: [PlanetPosition]
            
            public struct PlanetPosition: Codable {
                public let id: Int
                public let name: String
                public let longitude: Double
                public let is_retrograde: Bool
                public let position: Int
                public let degree: Double
                public let rasi: Rasi
                
                public struct Rasi: Codable {
                    public let id: Int
                    public let name: String
                    public let lord: Lord
                    public struct Lord: Codable {
                        public let id: Int
                        public let name: String
                        public let vedic_name: String
                    }
                }
            }
        }
    }
}
