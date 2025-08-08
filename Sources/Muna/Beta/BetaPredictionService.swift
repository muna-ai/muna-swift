/*
*   Muna
*   Copyright © 2025 NatML Inc. All rights reserved.
*/

/// Make predictions.
public class BetaPredictionService {

    /// Make remote predictions.
    public let remote: RemotePredictionService

    internal init(client: MunaClient) {
        self.remote = RemotePredictionService(client: client)
    }
}
