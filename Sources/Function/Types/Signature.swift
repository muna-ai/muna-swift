//
//  Signature.swift
//  Function
//
//  Created by Yusuf Olokoba on 10/21/2023.
//  Copyright © 2023 NatML Inc. All rights reserved.
//

import Foundation

/// Predictor signature.
public struct Signature : Codable {
    
    /// Prediction inputs.
    var inputs: [Parameter]
    
    /// Prediction outputs.
    var outputs: [Parameter]
}
