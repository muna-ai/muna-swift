/*
*   Muna
*   Copyright © 2025 NatML Inc. All rights reserved.
*/

public class PredictorService {

    private let client: MunaClient

    internal init(client: MunaClient) {
        self.client = client
    }

    public func retrieve(tag: String) async throws -> Predictor? {
        do {
            return try await client.request(method: "GET", path: "/predictors/\(tag)") as Predictor?
        } catch let error as MunaError {
            switch error {
                case .requestFailed(_, let status) where status == 404: return nil
                default: throw error
            }
        }
    }
}
