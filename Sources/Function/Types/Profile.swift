//
//  Profile.swift
//  Function
//
//  Created by Yusuf Olokoba on 10/21/2023.
//  Copyright © 2023 NatML Inc. All rights reserved.
//

import Foundation

/// Function user profile.
public struct Profile : Codable {
    
    /// Username.
    var username: String
    
    /// Date created.
    var created: String // If this should be a Date object instead, make sure to convert the string accordingly.
    
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
