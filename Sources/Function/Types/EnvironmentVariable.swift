//
//  EnvironmentVariable.swift
//  Function
//
//  Created by Yusuf Olokoba on 10/21/2023.
//  Copyright © 2023 NatML Inc. All rights reserved.
//

import Foundation

/// Predictor environment variable.
public struct EnvironmentVariable : Codable {
    
    /// Environment variable name.
    var name: String
    
    /// Environment variable value.
    var value: String?
    
    init (name: String, value: String? = nil) {
        self.name = name
        self.value = value
    }
}
