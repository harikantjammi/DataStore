//
//  DishaShoolDTO.swift
//  DataStore
//
//  Created by Harikant Jammi on 29/05/26.
//


import Foundation

public struct DishaShoolDTO: Codable {
    public let data: Data
    
    public struct Data: Codable {
        public let status: String
        public let data: Data
        
        public struct Data: Codable {
            public let disha_shool : DishaShool
            
            public struct DishaShool: Codable {
                public let direction: String
                public let remedy: String
                public let start: Date
                public let end: Date
            }
        }
    }
}
