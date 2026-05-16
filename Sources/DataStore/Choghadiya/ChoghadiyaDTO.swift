//
//  ChoghadiyaDTO.swift
//  PocketPanchangApp
//
//  Created by Harikant Jammi on 04/05/25.
//

import Foundation

struct ChoghadiyaDTO: Codable {
    let data: Data
    
    struct Data: Codable {
        let status: String
        let data: Data
        
        struct Data: Codable {
            let muhurat: [Muhurat]
            
            struct Muhurat: Codable {
                let id: Int
                let name: String
                let type: MuhuratType
                let vela: String?
                let is_day: Bool
                let start: Date
                let end: Date
                
                enum MuhuratType: String, Codable {
                    case inauspicious = "Inauspicious"
                    case auspicious = "Most Auspicious"
                    case good = "Good"
                }
            }
        }
    }
}
