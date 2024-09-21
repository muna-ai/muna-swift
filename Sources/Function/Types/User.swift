//
//  User.swift
//  Function
//
//  Created by Yusuf Olokoba on 10/21/2023.
//  Copyright © 2024 NatML Inc. All rights reserved.
//

import Foundation

/// Function user.
public struct User: Codable {
    
    /// Username.
    var username: String
    
    /// Date created.
    var created: Date
    
    /// User display name.
    var name: String?
    
    /// User avatar.
    var avatar: String?
    
    /// User bio.
    var bio: String?
    
    /// User website.
    var website: String?
    
    /// User GitHub handle.
    var github: String?
}
