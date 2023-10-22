//
//  UploadType.swift
//  Function
//
//  Created by Yusuf Olokoba on 10/21/2023.
//  Copyright © 2023 NatML Inc. All rights reserved.
//

import Foundation

/// Upload URL type.
public enum UploadType: String, Codable {
    
    /// Predictor media.
    case media = "MEDIA"
    
    /// Predictor notebook.
    case notebook = "NOTEBOOK"

    /// Prediction value.
    case value = "VALUE"
}
