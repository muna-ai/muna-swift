/*
*   Muna
*   Copyright © 2025 NatML Inc. All rights reserved.
*/

public class UserService {

    private let client: MunaClient

    internal init(client: MunaClient) {
        self.client = client
    }

    public func retrieve() async throws -> User? {
        do {
            return try await client.request(method: "GET", path: "/users") as User?
        } catch let error as MunaError {
            switch error {
                case .requestFailed(_, let status) where status == 401: return nil
                default: throw error
            }
        }
    }
}
