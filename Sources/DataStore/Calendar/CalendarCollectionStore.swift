//
//  CalendarCollectionStore.swift
//  DataStore
//
//  Created by Harikant Jammi on 29/05/26.
//


import Foundation
import SwiftData

@MainActor
public class CalendarCollectionStore {
    
    let context: ModelContext
    let appwrite = Appwrite.shared
    
    public init(context: ModelContext) {
        self.context = context
    }
    
    public func refreshCalendar(month: Int, year: Int) async throws {
        guard let storedCalendarEntryCollection = try lookUpCalendarCollection(month: month,
                                                                               year: year) else {
            try await fetchAndUpdateCalendarCollection(month: month, year: year)
            return
        }
        
        
        if storedCalendarEntryCollection.isInThresholdRange() {
            return
        }
        try deleteCalendarCollection(calendarCollection: storedCalendarEntryCollection)
        try await fetchAndUpdateCalendarCollection(month: month, year: year)
        
    }
    
    private func deleteCalendarCollection(calendarCollection: CalendarEntryCollection) throws {
        context.delete(calendarCollection)
        try context.save()
    }
    
    private func fetchAndUpdateCalendarCollection(month: Int, year: Int) async throws {
        let calendar = Calendar(identifier: .gregorian)
        let dayComponents = DateComponents(year: year, month: month, day: 1)
        let total = calendar.range(of: .day, in: .month, for: calendar.date(from: dayComponents)!)!.count
        let limit = 20
        let pageCount = Int(ceil(Double(total) / Double(limit)))
        var entries: [CalendarStore.Response.DTO] = []
        
        try await withThrowingTaskGroup(of: [CalendarStore.Response.DTO].self) { group in
            for page in 0..<pageCount {
                group.addTask {
                    return try await self.fetchCalendarBatchFromRemoteSource(month: month,
                                                                             year: year,
                                                                             offset: page*limit,
                                                                             limit: limit)
                }
            }
            
            do {
                for try await pageEntries in group {
                    entries.append(contentsOf: pageEntries)
                }
            } catch {
                group.cancelAll()
                // Re-throw with a more descriptive error
                throw NSError(
                    domain: "CalendarCollectionStore",
                    code: 1,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Failed to fetch calendar data: \(error.localizedDescription)",
                        NSUnderlyingErrorKey: error
                    ]
                )
            }
            
            
        }
        
        if entries.count != total {
            throw NSError(domain: "CalendarCollectionStore",
                          code: 1,
                          userInfo: [NSLocalizedDescriptionKey : "Failed to fetch all entries"])
        }
        
        try await insertCalendarBatch(entries, month: month, year: year)
        
    }
    
    
    
    
    private func lookUpCalendarCollection(month: Int, year: Int) throws -> CalendarEntryCollection? {
        let fetchDescriptor = FetchDescriptor<CalendarEntryCollection>(
            predicate: #Predicate { $0.month == month && $0.year == year }
        )
        return try context.fetch(fetchDescriptor).first
    }
    
    private func fetchCalendarBatchFromRemoteSource(month: Int, year: Int, offset: Int, limit: Int) async throws -> [CalendarStore.Response.DTO] {
        let path = "/calendar/months/\(year)-\(String(format: "%02d", month))"
        let queryItems = [URLQueryItem(name: "offset", value: String(offset)),
                          URLQueryItem(name: "limit", value: String(limit))]
        let response: [CalendarStore.Response.DTO] = try await appwrite.executeFunction("67b91e390034cf42f28e",
                                                                                  path: path,
                                                                                  queryItems: queryItems)
        return response
    }
    
    private func insertCalendarBatch(_ dtoEntries: [CalendarStore.Response.DTO], month: Int, year: Int) async throws {
        let calendarEntryCollection = CalendarEntryCollection(month: month,
                                                              year: year,
                                                              entries: dtoEntries.map { CalendarEntry(dto: $0) })
        context.insert(calendarEntryCollection)
        try context.save()
    }
}

extension CalendarEntryCollection {
    
    public func isInThresholdRange() -> Bool {
        let thresholdTimeInterval: Double = 60*60*24*7
        let now = Date()
        let thresholdDate = lastUpdated.addingTimeInterval(thresholdTimeInterval)
        return now < thresholdDate
    }
}

extension CalendarEntry {
    public convenience init(dto: CalendarStore.Response.DTO) {
        self.init(day: dto.day,
                  month: dto.month,
                  year: dto.year,
                  nakshatra: dto.nakshatra,
                  chandra_rasi: dto.chandra_rasi,
                  festival: dto.festival,
                  sk_pk: dto.sk_pk,
                  sk_pk_name: dto.sk_pk_name,
                  month_name_hindu: dto.month_name_hindu)
    }
}
