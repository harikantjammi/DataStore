//
//  ChandraBalaDTO.swift
//  DataStore
//
//  Created by Harikant Jammi on 29/05/26.
//

import Foundation

nonisolated public struct ChandraBalaDTO: Codable {
    public let data: Data
    
    public struct Data: Codable {
        public let status: String
        public let data: Data
        
        public struct Data: Codable {
            public let chandra_bala: [ChandraBala]
            
            public struct ChandraBala: Codable {
                public let start: Date
                public let end: Date
                
                public let rasis :[Rasi]
                
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
