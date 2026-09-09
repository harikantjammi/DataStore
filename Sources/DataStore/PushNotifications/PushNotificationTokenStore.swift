//
//  PushNotificationTokenStore.swift
//  PocketPanchangApp
//

import Foundation

public class PushNotificationTokenStore {
    private let appwrite = Appwrite.shared
    public init() {}
    
    public struct PushTargetBody: Codable {
        let token: String
    }
    
    public struct PushTargetResponse: Codable {}
    public struct PushTargetDeleteResponse: Codable {}
    
    private let functionId = "6a9cd1000029315abccf"
    
    public func addOrUpdatePushTarget(userId: String, token: String) async throws -> PushTargetResponse {
        return try await appwrite.executePOSTFunction(functionId,
                                                      path: "/users/\(userId)/push-target",
                                                      body: PushTargetBody(token: token))
    }
    
    public func deletePushTarget(userId: String) async throws -> PushTargetDeleteResponse {
        return try await appwrite.executeDELETEFunction(functionId,
                                                        path: "/users/\(userId)/push-target")
    }
    
    public struct UserNotificationPreferences: Codable {
        let general: Bool
        let festivals: Bool
    }
    
    public func getUserNotificationPreferences(userId: String) async throws -> UserNotificationPreferences {
        return try await appwrite.executeFunction(functionId, path: "/users/\(userId)/notification-preferences")
    }
    
    public func postUserNotificationPreferences(userId: String, preferences: UserNotificationPreferences) async throws -> UserNotificationPreferences {
        return try await appwrite.executePOSTFunction(functionId,
                                                      path: "/users/\(userId)/notification-preferences",
                                                      body: preferences)
    }
}
