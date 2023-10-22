//
//  AccessMode.swift
//  Function
//
//  Created by Yusuf Olokoba on 10/21/2023.
//  Copyright © 2023 NatML Inc. All rights reserved.
//

import Foundation

/// Access mode.
public enum AccessMode: String, Codable {
    
    /// Resource can be accessed by any user.
    case Public = "PUBLIC"
    
    /// Resource can only be accessed by the owner.
    case Private = "PRIVATE"
}
