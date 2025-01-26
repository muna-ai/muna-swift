//
//  User.swift
//  Function
//
//  Created by Yusuf Olokoba on 10/21/2023.
//  Copyright © 2025 NatML Inc. All rights reserved.
//

import Foundation

/// Function user.
public struct User: Codable {
    
    /// Username.
    public var username: String
    
    /// Date created.
    public var created: Date
    
    /// User display name.
    public var name: String?
    
    /// User avatar.
    public var avatar: String?
    
    /// User bio.
    public var bio: String?
    
    /// User website.
    public var website: String?
    
    /// User GitHub handle.
    public var github: String?
}
