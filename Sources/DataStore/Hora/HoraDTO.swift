//
//  HoraDTO.swift
//  PocketPanchangApp
//
//  Created by Harikant Jammi on 02/05/25.
//

import Foundation

struct HoraDTO: Codable {
    let data: Data
    
    struct Data: Codable {
        let status: String
        let data: Data
        
        struct Data: Codable {
            let hora_timing: [HoraTiming]
            
            struct HoraTiming: Codable {
                let hora: Hora
                let type: String
                let is_day: Bool
                let start: Date
                let end: Date
                
                struct Hora: Codable {
                    let id: Int
                    let name: String
                    let vedic_name: String
                }
            }
        }
    }

}

extension HoraDTO.Data.Data.HoraTiming {
    
    var isDay: Bool {
        return is_day
    }
    
    enum SeverityType {
        case good
        case bad
        case neutral
        
        init(value: String) {
            switch value.lowercased() {
            case "good":
                self = .good
            case "bad":
                self = .bad
            default:
                self = .neutral
            }
        }
    }
    
    var severityType: SeverityType {
        SeverityType(value: self.type)
    }
    
    var dateInterval: DateInterval {
        return DateInterval(start: start,
                            end: end)
    }
    
    var isActive: Bool {
        return dateInterval.contains(Date())
    }
}
