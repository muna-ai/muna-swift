//
//  ResultValue.swift
//  Function
//
//  Created by Yusuf Olokoba on 10/21/2023.
//  Copyright © 2023 NatML Inc. All rights reserved.
//

import Foundation

/// Prediction result value.
public enum ResultValue : Codable { // INCOMPLETE
    
    case int(Int)
    case double(Double)
    case string(String)
}
