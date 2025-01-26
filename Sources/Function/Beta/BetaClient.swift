//
//  BetaClient.swift
//  Function
//
//  Created by Yusuf Olokoba on 1/25/2025.
//  Copyright © 2025 NatML Inc. All rights reserved.
//

/// Client for incubating features.
public class BetaClient {

    /// Make predictions.
    public let predictions: BetaPredictionService

    internal init (client: FunctionClient) {
        self.predictions = BetaPredictionService(client: client)
    }
}
