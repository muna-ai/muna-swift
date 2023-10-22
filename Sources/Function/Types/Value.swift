//
//  Value.swift
//  Function
//
//  Created by Yusuf Olokoba on 10/21/2023.
//  Copyright © 2023 NatML Inc. All rights reserved.
//

import Foundation

/// Prediction value.
public struct Value: Codable {

    /// Value URL.
    var data: String?

    /// Value type.
    var type: Dtype

    /// Value shape.
    /// This is `nil` if shape information is not available or applicable.
    var shape: [Int]?
}
