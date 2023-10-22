//
//  PredictorType.swift
//  Function
//
//  Created by Yusuf Olokoba on 10/21/2023.
//  Copyright © 2023 NatML Inc. All rights reserved.
//

import Foundation

/// Predictor type.
public enum PredictorType : String, Codable {
    
    /// Predictions are run in the cloud.
    case Cloud = "CLOUD"
    
    /// Predictions are run on-device.
    case Edge = "EDGE"
}
