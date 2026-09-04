//
//  PushNotificationTokenStore.swift
//  PocketPanchangApp
//

import Foundation

public class PushNotificationTokenStore {
    public init() {}

    @discardableResult
    public func createPushTarget(token: String) async throws -> String {
        try await Appwrite.shared.createPushTarget(token: token)
    }
}
