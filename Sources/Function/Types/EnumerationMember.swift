//
//  EnumerationMember.swift
//  Function
//
//  Created by Yusuf Olokoba on 10/21/2023.
//  Copyright © 2023 NatML Inc. All rights reserved.
//

import Foundation

/// Prediction parameter enumeration member.
public struct EnumerationMember: Codable {
    
    /// Enumeration member name.
    var name: String
    
    /// Enumeration member value.
    var value: EnumerationValue
}

/// Prediction parameter enumeration value.
public enum EnumerationValue: Codable {
    
    case string(String)
    case int(Int)

    public init (from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intValue = try? container.decode(Int.self) {
            self = .int(intValue)
        } else if let stringValue = try? container.decode(String.self) {
            self = .string(stringValue)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid value. Expected either a string or an int.")
        }
    }

    public func encode (to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .int(let intValue):
            try container.encode(intValue)
        case .string(let stringValue):
            try container.encode(stringValue)
        }
    }
}
