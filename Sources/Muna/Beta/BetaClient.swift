/*
*   Muna
*   Copyright © 2025 NatML Inc. All rights reserved.
*/

/// Client for incubating features.
public class BetaClient {

    /// Make predictions.
    public let predictions: BetaPredictionService

    internal init(client: MunaClient) {
        self.predictions = BetaPredictionService(client: client)
    }
}
