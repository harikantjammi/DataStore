//
//  HinduCalendarComponents.swift
//  DataStore
//
//  Created by Harikant Jammi on 08/08/25.
//

//
//  HnduCalendarDateComponents.swift
//  PocketPanchangApp
//
//  Created by Harikant Jammi on 24/07/25.
//

import Foundation

public struct HinduCalendarDateComponents {
    public let paksha: Paksha
    public let tithi: Tithi
    public let month: String
    
    public enum Paksha: String {
        case shukla = "S"
        case krishna = "K"
        
        public var displayName: String {
            switch self {
            case .shukla: "Shukla Paksha"
            case .krishna: "Krishna Paksha"
            }
        }
    }
    
    public enum Tithi: Int {
        case pratipada = 1
        case dwitiya = 2
        case tritiya = 3
        case chaturthi = 4
        case panchami = 5
        case shashthi = 6
        case sapthami = 7
        case ashtami = 8
        case navami = 9
        case dashami = 10
        case ekadasi = 11
        case dwadashi = 12
        case trayodashi = 13
        case chaturdashi = 14
        case purnima = 15
        case amavasya = 30
        
        public var diplayName: String {
            switch self {
            case .pratipada: "Pratipada"
            case .dwitiya: "Dwitiya"
            case .tritiya: "Tritiya"
            case .chaturthi: "Chaturthi"
            case .panchami: "Panchami"
            case .shashthi: "Shashthi"
            case .sapthami: "Sapthami"
            case .ashtami: "Ashtami"
            case .navami: "Navami"
            case .dashami: "Dashami"
            case .ekadasi: "Ekadasi"
            case .dwadashi: "Dwadashi"
            case .trayodashi: "Trayodashi"
            case .chaturdashi: "Chaturdashi"
            case .purnima: "Purnima"
            case .amavasya: "Amavasya"
            }
        }
    }
    
    public init?(code: String, month: String) {
        guard code.count >= 2 else { return nil }
        let pakshaRawValue = String(code.prefix(1))
        guard let paksha = Paksha(rawValue: pakshaRawValue) else {
            return nil
        }
        
        guard let tithiRawValue = Int(String(code.dropFirst())) else {
            return nil
        }
        
        guard let tithi = Tithi(rawValue: tithiRawValue) else {
            return nil
        }
        
        self.paksha = paksha
        self.tithi = tithi
        self.month = month
    }
    
    public var displayValue: String {
        "\(tithi.diplayName), \(paksha.displayName) (\(month))"
    }
}

public extension HinduCalendarDateComponents {
    init?(calendarDayDetails: CalendarStore.Model.CalendarDayComponents) {
        guard let sk_pk = calendarDayDetails.sk_pk else { return nil }
        guard let month_name_hindu = calendarDayDetails.month_name_hindu else { return nil }
        self.init(code: sk_pk, month: month_name_hindu)
    }
}
