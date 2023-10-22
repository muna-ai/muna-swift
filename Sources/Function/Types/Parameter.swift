//
//  Parameter.swift
//  Function
//
//  Created by Yusuf Olokoba on 10/21/2023.
//  Copyright © 2023 NatML Inc. All rights reserved.
//

import Foundation

/// Predictor parameter.
public struct Parameter : Codable {
    
    /// Parameter name.
    var name: String?
    
    /// Parameter type.
    var type: Dtype?
    
    /// Parameter description.
    var description: String?
    
    /// Parameter is optional.
    var optional: Bool?
    
    /// Parameter value range for numeric parameters.
    var range: [Float]?
    
    /// Parameter value choices for enumeration parameters.
    var enumeration: [EnumerationMember]?
    
    /// Parameter default value.
    var defaultValue: Value?
}
