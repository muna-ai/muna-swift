//
//  Prediction.swift
//  Function
//
//  Created by Yusuf Olokoba on 10/21/2023.
//  Copyright © 2024 NatML Inc. All rights reserved.
//

import Foundation

/// Prediction.
public struct Prediction : Codable {
    
    /// Prediction ID.
    var id: String
    
    /// Predictor tag.
    var tag: String
    
    /// Date created.
    var created: Date
    
    /// Prediction results.
    var results: [Any]?
    
    /// Prediction latency in milliseconds.
    var latency: Float?
    
    /// Prediction error.
    var error: String?
    
    /// Prediction logs.
    var logs: String?
    
    /// Prediction resources.
    var resources: [PredictionResource]?
        
    /// Prediction configuration token.
    var configuration: String?
    
    private enum CodingKeys: String, CodingKey {
        case id, tag, created, latency, error, logs, resources
    }
}

/// Prediction resource.
public struct PredictionResource : Codable {
    
    /// Resource type.
    var type: String
    
    /// Resource URL.
    var url: String
    
    /// Resource name.
    var name: String?
}

/// Prediction  acceleration.
public enum Acceleration: Int, Codable {
    
    /// Use the default acceleration for the given platform.
    case auto = 0
    
    /// Predictions run on the CPU.
    case cpu = 0b001
    
    /// Predictions run on the GPU..
    case gpu = 0b010
    
    /// Predictions run on the neural processor..
    case npu = 0b100
}
