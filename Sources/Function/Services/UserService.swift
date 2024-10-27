//
//  User.swift
//  Function
//
//  Created by Yusuf Olokoba on 9/21/2024.
//  Copyright © 2024 NatML Inc. All rights reserved.
//

public class UserService {

    private let client: FunctionClient

    internal init (client: FunctionClient) {
        self.client = client
    }

    public func retrieve () async throws -> User? {
        do {
            return try await client.request(method: "GET", path: "/users") as User?
        } catch let error as FunctionError {
            switch error {
                case .requestFailed(_, let status) where status == 401: return nil
                default: throw error
            }
        }
    }
}
