//
//  Tag.swift
//  Function
//
//  Created by Yusuf Olokoba on 10/21/2023.
//  Copyright © 2023 NatML Inc. All rights reserved.
//

import Foundation

/// Predictor tag.
public struct Tag {
    
    // Predictor owner username.
    let username: String
    
    // Predictor name.
    let name: String
    
    /// Create a tag.
    init (username: String, name: String) {
        self.username = username
        self.name = name
    }

    /// Serialize the tag.
    func description () -> String {
        return "@\(username)/\(name)"
    }

    /// Try to parse a predictor tag from a string.
    static func tryParse (input: String) -> Tag? {
        let sanitizedInput = input.lowercased()
        guard sanitizedInput.hasPrefix("@") else { return nil }
        let stem = sanitizedInput.split(separator: "/").map { String($0) }
        guard stem.count == 2 else { return nil }
        let username = String(stem[0].dropFirst())
        let name = stem[1]
        return Tag(username: username, name: name)
    }
}
