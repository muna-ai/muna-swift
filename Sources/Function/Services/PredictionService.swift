//
//  PredictionService.swift
//  Function
//
//  Created by Yusuf Olokoba on 9/21/2024.
//  Copyright © 2024 NatML Inc. All rights reserved.
//

import Foundation
import Function

public class PredictionService {

    private let client: FunctionClient

    internal init (client: FunctionClient) {
        self.client = client
    }

    public func create (
        tag: String,
        inputs: [String: Any?]? = nil,
        acceleration: Acceleration = .auto,
        device: UnsafeRawPointer? = nil,
        clientId: String? = nil,
        configurationId: String? = nil
    ) async throws -> Prediction? {
        return nil
    }

    public func stream (
        tag: String,
        inputs: [String: Any],
        acceleration: Acceleration = .auto,
        device: UnsafeRawPointer? = nil
    ) async throws -> AsyncStream<Prediction> {
        return AsyncStream { continuation in
            continuation.finish()
        }
    }
    
    private func createRawPrediction (
        tag: String,
        clientId: String? = nil,
        configurationId: String? = nil
    ) async throws -> Prediction? {
        return try await client.request(
            method: "POST",
            path: "/predictions",
            payload: [
                "tag": tag,
                "clientId": clientId ?? Configuration.clientId,
                "configurationId": configurationId ?? Configuration.uniqueId
            ]
        )
    }
    
    private func getResourceName (url: String) -> String {
        guard let uri = URL(string: url) else { return "" }
        return uri.lastPathComponent
    }
}
