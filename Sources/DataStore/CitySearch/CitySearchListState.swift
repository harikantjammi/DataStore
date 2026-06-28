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
    public let searchSubject = PassthroughSubject<String, Never>()
    let appWriteClient = Appwrite.shared
    
    public init() {
        cancellable = searchSubject
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .map { [weak self] searchText -> AnyPublisher<[City], Never> in
                guard let self = self else {
                    return Just([]).eraseToAnyPublisher()
                }
                return self.performSearch(searchText)
            }
            .switchToLatest()
            .eraseToAnyPublisher()
            .assign(to: \.cities, on: self)
        
    }
    
    public func resetResults() {
        self.cities = []
    }
    
    
    
    private func performSearch(_ searchText: String) -> AnyPublisher<[City], Never> {
        self.isLoading = true
        self.cities = []
        if searchText.isEmpty || self.searchText.count < 3 {
            self.isLoading = false
            return Just([]).eraseToAnyPublisher()
        }
        let publisher: AnyPublisher<CitySearchResponse, Error> = appWriteClient.executeFunctionPublisher("6788e8bf000f944e2335",
                                                                                                         path: "/cities",
                                                                                                         queryItems: [URLQueryItem(name: "query",
                                                                                                                                   value: searchText)])
        return publisher
            .map {(value: CitySearchResponse) in value.data }
            .replaceError(with: [])
            .map { $0.map {
                City(id: $0.place_id,
                     name: $0.address.name ?? "",
                     country: $0.address.country ?? "",
                     location: CLLocation(latitude: Double($0.lat)!,
                                          longitude: Double($0.lon)!),
                     state: $0.address.state ?? "")
            }
            }
            .handleEvents(
                receiveCompletion: { [weak self] _ in
                    // Set loading to false when the publisher completes (success or failure)
                    self?.isLoading = false
                },
                receiveCancel: { [weak self] in
                    // Set loading to false if the subscription is cancelled
                    self?.isLoading = false
                    self?.cities = []
                }
            )
            .eraseToAnyPublisher()
    }
}

nonisolated public struct CitySearchResponse: Codable, Sendable {
    public let data: [CitySearchResult]
}
nonisolated public struct CitySearchResult: Codable, Sendable {
    public let place_id: String
    public let lat: String
    public let lon: String
    public let address: Address

    nonisolated public struct Address: Codable, Sendable {
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
