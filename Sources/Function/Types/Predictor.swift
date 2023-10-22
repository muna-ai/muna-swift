//
//  Predictor.swift
//  Function
//
//  Created by Yusuf Olokoba on 10/21/2023.
//  Copyright © 2023 NatML Inc. All rights reserved.
//

import Foundation

/// Prediction function.
public struct Predictor : Codable {
    
    /// Predictor tag.
    var tag: String
    
    /// Predictor owner.
    var owner: Profile
    
    /// Predictor name.
    var name: String
    
    /// Predictor type.
    var type: PredictorType
    
    /// Predictor status.
    var status: PredictorStatus
    
    /// Number of predictions made with this predictor.
    var predictions: Int
    
    /// Date created.
    var created: Date
    
    /// Predictor description.
    var description: String?
    
    /// Predictor card.
    var card: String?
    
    /// Predictor media URL.
    /// We encourage animated GIFs where possible.
    var media: String?
    
    /// Predictor acceleration.
    /// This only applies to `CLOUD` predictors.
    var acceleration: Acceleration?
    
    /// Predictor signature.
    var signature: Signature?
    
    /// Predictor provisioning error.
    /// This is populated when the predictor status is `INVALID`.
    var error: String?
    
    /// Predictor license URL.
    var license: String?
}
