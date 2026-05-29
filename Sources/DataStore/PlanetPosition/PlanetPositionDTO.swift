//
//  PlanetPositionDTO.swift
//  DataStore
//
//  Created by Harikant Jammi on 29/05/26.
//
import Foundation

struct PlanetPositionDTO: Codable {
    let data: Data
    struct Data: Codable {
        let status: String
        let data: Data
        
        struct Data: Codable {
            let planet_position: [PlanetPosition]
            
            struct PlanetPosition: Codable {
                let id: Int
                let name: String
                let longitude: Double
                let is_retrograde: Bool
                let position: Int
                let degree: Double
                let rasi: Rasi
                
                struct Rasi: Codable {
                    let id: Int
                    let name: String
                    let lord: Lord
                    struct Lord: Codable {
                        let id: Int
                        let name: String
                        let vedic_name: String
                    }
                }
            }
        }
    }
}
