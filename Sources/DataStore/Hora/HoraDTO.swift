//
//  HoraDTO.swift
//  PocketPanchangApp
//
//  Created by Harikant Jammi on 02/05/25.
//

import Foundation

nonisolated public struct HoraDTO: Codable, Sendable {
    public let data: Data
    
    public struct Data: Codable, Sendable  {
        public let status: String
        public let data: Data
        
        public struct Data: Codable, Sendable  {
            public let hora_timing: [HoraTiming]
            
            public  struct HoraTiming: Codable, Sendable  {
                public let hora: Hora
                public let type: String
                public let is_day: Bool
                public let start: Date
                public let end: Date
                
                public struct Hora: Codable, Sendable  {
                    public let id: Int
                    public let name: String
                    public let vedic_name: String
                }
            }
        }
    }

}

nonisolated public extension HoraDTO.Data.Data.HoraTiming {
    
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
