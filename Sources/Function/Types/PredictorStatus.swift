//
//  PredictorStatus.swift
//  Function
//
//  Created by Yusuf Olokoba on 10/21/2023.
//  Copyright © 2023 NatML Inc. All rights reserved.
//

import Foundation

/// Predictor status.
public enum PredictorStatus : String, Codable {
    
    /// Predictor is being provisioned.
    case Provisioning = "PROVISIONING"
    
    /// Predictor is active.
    case Active = "ACTIVE"
    
    /// Predictor is invalid.
    case Invalid = "INVALID"
    
    /// Predictor is archived.
    case Archived = "ARCHIVED"
}
