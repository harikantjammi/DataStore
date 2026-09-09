//
//  UserSession.swift
//  DataStore
//
//  Created by Harikant Jammi on 09/09/26.
//

public class UserSession {
    public struct Data {
        let id: String
    }
    let appwrite: Appwrite = Appwrite.shared
    
    public init() {
        
    }
    
    public func getSession() async throws -> UserSession.Data {
        let id = try await appwrite.getUserSession().id
        return .init(id: id)
    }
}
