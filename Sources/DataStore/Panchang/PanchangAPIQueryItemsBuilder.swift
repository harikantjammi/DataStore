//
//  PanchangAPIQueryItemsBuilder.swift
//  PocketPanchangApp
//
//  Created by Harikant Jammi on 25/03/25.
//
import Foundation

public class PanchangAPIQueryItemsBuilder {
    private var queryItems: [String: URLQueryItem] = [:]
    public init() {
        
    }
    @discardableResult
    func setAyanamsa(_ ayanamsa: Ayanamsa) -> Self {
        queryItems["ayanamsa"] = URLQueryItem(name: "ayanamsa", value: "\(ayanamsa.rawValue)")
        return self
    }
    
    @discardableResult
    func setDate(_ date: Date, tz: String) -> Self {
        let timezone = TimeZone(identifier: tz)!
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = timezone
        let dateString = formatter.string(from: date)
        let dateStringSplitByT = dateString.split(separator: "T")
        let dateSplitFirstPart = dateStringSplitByT[0]
            
        let dateSplitSecondPart = dateStringSplitByT[1]
            .replacingOccurrences(of: ":", with: "%3A")
            .replacingOccurrences(of: "+", with: "%2B")
            .replacingOccurrences(of: "-", with: "%2D")
        
        
        
        queryItems["datetime"] = URLQueryItem(name: "datetime",
                                              value: dateSplitFirstPart + "T" + dateSplitSecondPart)
        return self
    }
    
    @discardableResult
    func set(latitude: Double, longitude: Double) -> Self {
        let longitudeString = (longitude < 0) ? "%2D\(abs(longitude))" : "\(longitude)"
        queryItems["coordinates"] = URLQueryItem(name: "coordinates", value: "\(latitude)%2C\(longitudeString)")
        return self
    }
    
    @discardableResult
    func setCalendarDate(date: Date, tz: String) -> Self {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: tz)
        queryItems["date"] = URLQueryItem(name: "date",
                                          value: formatter.string(from: date))
        return self
    }
    
    @discardableResult
    func setCalendarType(_ calendarType: CalendarDateDisplayType) -> Self {
        queryItems["calendar"] = URLQueryItem(name: "calendar",
                                              value: calendarType.rawValue)
        return self
    }
    
    func build() -> [URLQueryItem] {
        queryItems["la"] = URLQueryItem(name: "la", value: "en")
        return queryItems.values.sorted { $0.name < $1.name }.compactMap { $0 }
    }
}
