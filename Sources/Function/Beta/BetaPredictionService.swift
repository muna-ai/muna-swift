//
//  PredictionService.swift
//  Function
//
//  Created by Yusuf Olokoba on 1/25/2025.
//  Copyright © 2025 NatML Inc. All rights reserved.
//

/// Make predictions.
public class BetaPredictionService {

    /// Make remote predictions.
    public let remote: RemotePredictionService

    internal init (client: FunctionClient) {
        self.remote = RemotePredictionService(client: client)
    }
}
