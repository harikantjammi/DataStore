//
//  Appwrite.swift
//  PocketPanchangApp
//
//  Created by Harikant Jammi on 02/03/25.
//

import Foundation
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

extension Appwrite {
    struct SessionModel {
        let id: String
    }
}


nonisolated final class Appwrite: @unchecked Sendable {
    private let appwriteClient: Client
    private let functions: Functions
    private let account: Account
    private let logger = Logger(subsystem: "PocketPanchangApp", category: "Appwrite")
    private let signposter = OSSignposter(subsystem: "PocketPanchangApp", category: "Appwrite")
    
    static let shared: Appwrite = .init()
    
    init() {
        self.appwriteClient = Client()
            .setEndpoint("https://cloud.appwrite.io/v1")
            .setProject("676ab30f002c611f24ce")
            .setSelfSigned(true)
        self.functions = Functions(appwriteClient)
        self.account = Account(appwriteClient)
    }
    
    func getUserSession() async throws -> SessionModel {
        do {
            if let user = try? await account.get().id {
                return SessionModel(id: user)
            } else {
                _ = try await account.createAnonymousSession()
                return SessionModel(id: try await account.get().id)
            }
        } catch {
            throw AppError.general(error: error)
        }
    }
    
    @discardableResult
    func createPushTarget(token: String, providerId: String? = nil) async throws -> String {
        do {
            let target = try await account.createPushTarget(
                targetId: ID.unique(),
                identifier: token,
                providerId: providerId
            )

            return target.id
        } catch _ as AsyncHTTPClient.HTTPClient.NWPOSIXError {
            throw AppError.noNetwork
        } catch {
            throw AppError.general(error: error)
        }
    }
    
    public func executePOSTFunction<T: Codable, Body: Encodable>(
        _ functionID: String,
        path: String,
        queryItems: [URLQueryItem] = [],
        body: Body
    ) async throws -> T {
        try await performExecution(method: "POST", path: path, queryItems: queryItems) { finalPath in
            let jsonEncoder = JSONEncoder()
            jsonEncoder.dateEncodingStrategy = .iso8601
            let bodyData = try jsonEncoder.encode(body)
            guard let bodyString = String(data: bodyData, encoding: .utf8) else {
                throw AppError.emptyResponse
            }
            return try await functions.createExecution(
                functionId: functionID,
                body: bodyString,
                path: finalPath,
                method: .pOST,
                headers: ["content-type": "application/json"]
            ).responseBody
        }
    }

    public func executeDELETEFunction<T: Codable>(
        _ functionID: String,
        path: String,
        queryItems: [URLQueryItem] = []
    ) async throws -> T {
        try await performExecution(method: "DELETE", path: path, queryItems: queryItems) { finalPath in
            try await functions.createExecution(functionId: functionID, path: finalPath, method: .dELETE).responseBody
        }
    }

    func executeFunction<T: Codable>(_ functionID: String, path: String, queryItems: [URLQueryItem] = []) async throws -> T {
        try await performExecution(method: "GET", path: path, queryItems: queryItems) { finalPath in
            try await functions.createExecution(functionId: functionID, path: finalPath, method: .gET).responseBody
        }
    }

    private func performExecution<T: Codable>(
        method: String,
        path: String,
        queryItems: [URLQueryItem],
        execute: (_ finalPath: String) async throws -> String
    ) async throws -> T {
        var urlComponents = URLComponents(string: path)!
        urlComponents.queryItems = queryItems
        let finalPath = urlComponents.path + "?" + (urlComponents.query ?? "")
        let clock = ContinuousClock()
        let requestStart = clock.now
        let signpostID = signposter.makeSignpostID()
        let signpostState = signposter.beginInterval("Appwrite Function", id: signpostID, "\(method, privacy: .public) \(finalPath, privacy: .public)")
        logger.debug("Starting Appwrite \(method, privacy: .public) request path=\(finalPath, privacy: .public)")

        do {
            let response = try await execute(finalPath)
            let networkDuration = requestStart.duration(to: clock.now)
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
                "Completed Appwrite \(method, privacy: .public) request path=\(finalPath, privacy: .public) network_ms=\(networkDuration.milliseconds) decode_ms=\(decodeDuration.milliseconds) total_ms=\(totalDuration.milliseconds)"
            )
            signposter.endInterval("Appwrite Function", signpostState, "network_ms=\(networkDuration.milliseconds) total_ms=\(totalDuration.milliseconds)")

            return decodedValue
        } catch _ as AsyncHTTPClient.HTTPClient.NWPOSIXError {
            let totalDuration = requestStart.duration(to: clock.now)
            logger.error("Appwrite \(method, privacy: .public) request failed path=\(finalPath, privacy: .public) total_ms=\(totalDuration.milliseconds) error=No network")
            signposter.endInterval("Appwrite Function", signpostState, "failed total_ms=\(totalDuration.milliseconds)")
            throw AppError.noNetwork
        } catch {
            let totalDuration = requestStart.duration(to: clock.now)
            logger.error("Appwrite \(method, privacy: .public) request failed path=\(finalPath, privacy: .public) total_ms=\(totalDuration.milliseconds) error=\(error.localizedDescription, privacy: .public)")
            signposter.endInterval("Appwrite Function", signpostState, "failed total_ms=\(totalDuration.milliseconds)")
            throw AppError.general(error: error)
        }
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
