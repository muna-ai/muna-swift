//
//  Prediction.swift
//  Function
//
//  Created by Yusuf Olokoba on 10/21/2023.
//  Copyright © 2023 NatML Inc. All rights reserved.
//

import Foundation

/// Prediction.
public struct Prediction : Codable {
    
    /// Prediction ID.
    var id: String
    
    /// Predictor tag.
    var tag: String
    
    /// Predictor type.
    var type: PredictorType
    
    /// Date created.
    var created: Date
    
    /// Prediction results.
    var results: [ResultValue]?
    
    /// Prediction latency in milliseconds.
    var latency: Float?
    
    /// Prediction error.
    /// This is `null` if the prediction completed successfully.
    var error: String?
    
    /// Prediction logs.
    var logs: String?
}
