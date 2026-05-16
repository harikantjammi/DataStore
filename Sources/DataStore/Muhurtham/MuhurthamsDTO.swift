//
//  MuhurthamsDTO.swift
//  PocketPanchangApp
//
//  Created by Harikant Jammi on 27/03/25.
//

import Foundation

struct MuhurthamsDTO: Codable {
    let data: Data
    
    struct Data: Codable {
        let data: Data
        struct Data: Codable {
            let muhurat: [Muhurthams]
            
            struct Muhurthams: Codable {
                let id: Int
                let name: String
                let type: String
                let period: [Period]
                
                struct Period: Codable {
                    let start: Date
                    let end: Date
                }
            }
        }
    }
    

}
