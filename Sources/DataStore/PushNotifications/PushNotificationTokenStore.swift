//
//  PushNotificationTokenStore.swift
//  PocketPanchangApp
//

import Foundation

public class PushNotificationTokenStore {
    enum Environment {
        case sandbox
        case production

        var functionId: String {
            switch self {
            case .sandbox:    return "6a9cd1000029315abccf"
            case .production: return "6aa5ecb9000d675aec60" // TODO: replace with production function id
            }
        }
    }

    private let appwrite = Appwrite.shared
    private let environment: Environment

    public init() {
        let raw = Bundle.main.object(forInfoDictionaryKey: "PushEnvironment") as? String
        self.environment = (raw?.lowercased() == "production") ? .production : .sandbox
    }

    public struct PushTargetBody: Codable {
        let token: String
    }

    public struct PushTargetResponse: Codable {}
    public struct PushTargetDeleteResponse: Codable {}

    public func addOrUpdatePushTarget(userId: String, token: String) async throws -> PushTargetResponse {
        return try await appwrite.executePOSTFunction(environment.functionId,
                                                      path: "/users/\(userId)/push-target",
                                                      body: PushTargetBody(token: token))
    }

    public func deletePushTarget(userId: String) async throws -> PushTargetDeleteResponse {
        return try await appwrite.executeDELETEFunction(environment.functionId,
                                                        path: "/users/\(userId)/push-target")
    }

    public struct UserNotificationPreferences: Codable {
        public let key: String
        public let value: Bool
        
        public init(key: String, value: Bool) {
            self.key = key
            self.value = value
        }
    }

    public func getUserNotificationPreferences(userId: String) async throws -> [UserNotificationPreferences] {
        return try await appwrite.executeFunction(environment.functionId, path: "/users/\(userId)/notification-preferences")
    }

    public func postUserNotificationPreferences(userId: String, preferences: [UserNotificationPreferences]) async throws -> [UserNotificationPreferences] {
        return try await appwrite.executePOSTFunction(environment.functionId,
                                                      path: "/users/\(userId)/notification-preferences",
                                                      body: preferences)
    }
}
