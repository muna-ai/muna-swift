/*
*   Muna
*   Copyright © 2025 NatML Inc. All rights reserved.
*/

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
public struct Acceleration: OptionSet {

    public let rawValue: UInt32

    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }

    /// Automatically choose the best acceleration for the predictor.
    public static let auto = Acceleration([])

    /// Predictions run on the CPU.
    public static let cpu = Acceleration(rawValue: 0b001)

    /// Predictions run on the GPU.
    public static let gpu = Acceleration(rawValue: 0b010)

    /// Predictions run on the Neural Engine.
    public static let npu = Acceleration(rawValue: 0b100)
}
