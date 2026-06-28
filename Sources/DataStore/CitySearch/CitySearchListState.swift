//
//  CitySearchListState.swift
//  DataStore
//
//  Created by Harikant Jammi on 29/05/26.
//


import Observation
import Combine
import MapKit
import CoreLocation

@Observable
public class CitySearchListState {
    public var searchText: String = "" {
        didSet {
            searchSubject.send(searchText)
        }
    }

    public var isLoading: Bool = false

    public var cities: [City] = []
    private var cancellable: AnyCancellable?
    private var searchTask: Task<Void, Never>?
    public let searchSubject = PassthroughSubject<String, Never>()
    let appWriteClient = Appwrite.shared

    public init() {
        cancellable = searchSubject
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .sink { [weak self] searchText in
                guard let self else { return }
                self.searchTask?.cancel()
                self.searchTask = Task { [weak self] in
                    await self?.performSearch(searchText)
                }
            }
    }

    public func resetResults() {
        self.cities = []
    }

    private func performSearch(_ searchText: String) async {
        self.isLoading = true
        self.cities = []
        if searchText.isEmpty || searchText.count < 3 {
            self.isLoading = false
            return
        }
        defer { self.isLoading = false }
        do {
            let response: CitySearchResponse = try await appWriteClient.executeFunction(
                "6788e8bf000f944e2335",
                path: "/cities",
                queryItems: [URLQueryItem(name: "query", value: searchText)])
            guard !Task.isCancelled else { return }
            self.cities = response.data.map { result in
                City(id: result.place_id,
                     name: result.address.name ?? "",
                     country: result.address.country ?? "",
                     location: CLLocation(latitude: Double(result.lat)!,
                                          longitude: Double(result.lon)!),
                     state: result.address.state ?? "")
            }
        } catch {
            self.cities = []
        }
    }
}

public struct CitySearchResponse: Codable {
    public let data: [CitySearchResult]
}
public struct CitySearchResult: Codable {
    public let place_id: String
    public let lat: String
    public let lon: String
    public let address: Address

    public struct Address: Codable {
        public let name: String?
        public let city: String?
        public let state: String?
        public let postCode: String?
        public let country: String?
        public let country_code: String?
        public let county: String?
        public let suburb: String?
        public let neighbourhood: String?
        public let town: String?
        
        public var availableName: String? {
            return name ?? city ?? county ?? suburb ?? neighbourhood ?? town
        }
    }
}


import CoreLocation
public struct City: Identifiable {
    public let id: String
    public let name: String
    public let country: String
    public let location: CLLocation
    public let state: String
}




extension City: Equatable, Hashable {
    public static func == (lhs: City, rhs: City) -> Bool {
        lhs.id == rhs.id && lhs.name == rhs.name && lhs.country == rhs.country && lhs.location == rhs.location
    }
    
}

extension CLLocationCoordinate2D: @retroactive Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
