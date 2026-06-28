//
//  Appwrite.swift
//  PocketPanchangApp
//
//  Created by Harikant Jammi on 02/03/25.
//

import Foundation
import Combine
import NIOCore
import NIO
import AsyncHTTPClient
import OSLog


import Appwrite
public enum AppError: Error, CustomNSError, LocalizedError {
    case emptyResponse
    case noNetwork
    case general(error: Error)
    
    static var domain: String { "com.appwrite.pocketpanchangapp" }
    
    public var errorCode: Int {
        switch self {
        case .emptyResponse:
            return 400
        case .general(_):
            return 500
        case .noNetwork:
            return 600
        }
    }
    
    public var errorDescription: String? {
        switch self {
        case .emptyResponse:
            return "Data not available"
        case .general(_):
            return "General error"
        case .noNetwork:
            return "No network"
        }
    }
    
    public var failureReason: String? {
        switch self {
        case .emptyResponse:
            return "No data was returned from the server."
        case .general(_):
            return "General failure was observed"
        case .noNetwork:
            return "No network connection is available."
        }
    }
}


nonisolated final class Appwrite: @unchecked Sendable {
    private let appwriteClient: Client
    private let functions: Functions
    private let logger = Logger(subsystem: "PocketPanchangApp", category: "Appwrite")
    private let signposter = OSSignposter(subsystem: "PocketPanchangApp", category: "Appwrite")
    
    static let shared: Appwrite = .init()
    
    init() {
        self.appwriteClient = Client()
            .setEndpoint("https://cloud.appwrite.io/v1")
            .setProject("676ab30f002c611f24ce")
            .setSelfSigned(true)
        self.functions = Functions(appwriteClient)
    }
    
    func executeFunction<T: Codable>(_ functionID: String, path: String, queryItems: [URLQueryItem] = []) async throws -> T {
        var urlComponents = URLComponents(string: path)!
        urlComponents.queryItems = queryItems
        let finalPath = urlComponents.path + "?" + (urlComponents.query ?? "")
        let clock = ContinuousClock()
        let requestStart = clock.now
        let signpostID = signposter.makeSignpostID()
        let signpostState = signposter.beginInterval("Appwrite Function", id: signpostID, "\(finalPath, privacy: .public)")
        logger.debug("Starting Appwrite request path=\(finalPath, privacy: .public)")

        do {
            let execution = try await functions.createExecution(functionId: functionID, path: finalPath, method: .gET)
            let networkDuration = requestStart.duration(to: clock.now)
            let response = execution.responseBody
            logger.debug("\(response)")
            if response.isEmpty {
                throw AppError.emptyResponse
            }
            guard let data = response.data(using: .utf8) else {
                throw AppError.emptyResponse
            }

            let decodeStart = clock.now
            let jsonDecoder = JSONDecoder()
            jsonDecoder.dateDecodingStrategy = .iso8601
            let decodedValue = try jsonDecoder.decode(T.self, from: data)
            let decodeDuration = decodeStart.duration(to: clock.now)
            let totalDuration = requestStart.duration(to: clock.now)

            logger.info(
                "Completed Appwrite request path=\(finalPath, privacy: .public) network_ms=\(networkDuration.milliseconds) decode_ms=\(decodeDuration.milliseconds) total_ms=\(totalDuration.milliseconds)"
            )
            signposter.endInterval("Appwrite Function", signpostState, "network_ms=\(networkDuration.milliseconds) total_ms=\(totalDuration.milliseconds)")
            
            return decodedValue
            
        } catch _ as AsyncHTTPClient.HTTPClient.NWPOSIXError {
            let totalDuration = requestStart.duration(to: clock.now)
            logger.error("Appwrite request failed path=\(finalPath, privacy: .public) total_ms=\(totalDuration.milliseconds) error=No network")
            signposter.endInterval("Appwrite Function", signpostState, "failed total_ms=\(totalDuration.milliseconds)")
            throw AppError.noNetwork
        } catch {
            let totalDuration = requestStart.duration(to: clock.now)
            logger.error("Appwrite request failed path=\(finalPath, privacy: .public) total_ms=\(totalDuration.milliseconds) error=\(error.localizedDescription, privacy: .public)")
            signposter.endInterval("Appwrite Function", signpostState, "failed total_ms=\(totalDuration.milliseconds)")
            throw AppError.general(error: error)
        }
    }
    
    public func executeFunctionPublisher<T: Codable & Sendable>(_ functionID: String, path: String, queryItems: [URLQueryItem] = []) -> AnyPublisher<T, Error> {
        let client = self
        return Deferred {
            Future { promise in
                let promiseBox = FuturePromiseBox(promise)
                Task {
                    do {
                        let value: T = try await client.executeFunction(functionID, path: path, queryItems: queryItems)
                        promiseBox.complete(.success(value))
                    } catch {
                        promiseBox.complete(.failure(error))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

nonisolated private final class FuturePromiseBox<Output>: @unchecked Sendable {
    private let promise: Future<Output, Error>.Promise

    init(_ promise: @escaping Future<Output, Error>.Promise) {
        self.promise = promise
    }

    func complete(_ result: Result<Output, Error>) {
        promise(result)
    }
}

nonisolated private extension Duration {
    var milliseconds: Int64 {
        let components = self.components
        let secondsInMilliseconds = Int64(components.seconds) * 1_000
        let attosecondsPerMillisecond: Int64 = 1_000_000_000_000_000
        let attosecondsInMilliseconds = Int64(components.attoseconds / attosecondsPerMillisecond)
        return secondsInMilliseconds + attosecondsInMilliseconds
    }
}
