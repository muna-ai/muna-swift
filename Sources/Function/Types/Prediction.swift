//
//  Prediction.swift
//  Function
//
//  Created by Yusuf Olokoba on 10/21/2023.
//  Copyright © 2025 NatML Inc. All rights reserved.
//

import Foundation

/// Prediction.
public struct Prediction: Codable {

    /// Prediction ID.
    public var id: String

    /// Predictor tag.
    public var tag: String

    /// Date created.
    public var created: Date

    /// Prediction results.
    public var results: [Any?]?

    /// Prediction latency in milliseconds.
    public var latency: Double?

    /// Prediction error.
    public var error: String?

    /// Prediction logs.
    public var logs: String?

    /// Prediction configuration token.
    public var configuration: String?

    /// Prediction resources.
    public var resources: [PredictionResource]?

    private enum CodingKeys: String, CodingKey {
        case id, tag, created, latency, error, logs, configuration, resources
    }
}

/// Prediction resource.
public struct PredictionResource: Codable {

    /// Resource type.
    public var type: String

    /// Resource URL.
    public var url: String

    /// Resource name.
    public var name: String?
}

/// Prediction  acceleration.
public enum Acceleration: UInt32, Codable {

    /// Automatically choose the best acceleration for the predictor.
    case auto = 0

    /// Predictions run on the CPU.
    case cpu = 0b001

    /// Predictions run on the GPU..
    case gpu = 0b010

    /// Predictions run on the neural processor..
    case npu = 0b100
}
