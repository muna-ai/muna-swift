//
//  Predictor.swift
//  Function
//
//  Created by Yusuf Olokoba on 10/21/2023.
//  Copyright © 2025 NatML Inc. All rights reserved.
//

import Foundation

/// Prediction function.
public struct Predictor: Codable {
    
    /// Predictor tag.
    public var tag: String
    
    /// Predictor owner.
    public var owner: User
    
    /// Predictor name.
    public var name: String

    /// Predictor access.
    public var access: AccessMode
    
    /// Predictor status.
    public var status: PredictorStatus
    
    /// Date created.
    public var created: Date
    
    /// Predictor description.
    public var description: String?
    
    /// Predictor card.
    public var card: String?
    
    /// Predictor media URL.
    public var media: String?
    
    /// Predictor signature.
    public var signature: Signature?
    
    /// Predictor provisioning error.
    /// This is populated when the predictor status is `INVALID`.
    public var error: String?
    
    /// Predictor license URL.
    public var license: String?
}

/// Predictor signature.
public struct Signature : Codable {
    
    /// Prediction inputs.
    public var inputs: [Parameter]
    
    /// Prediction outputs.
    public var outputs: [Parameter]
}

/// Predictor parameter.
public struct Parameter : Codable {
    
    /// Parameter name.
    public var name: String?
    
    /// Parameter type.
    public var type: Dtype?
    
    /// Parameter description.
    public var description: String?
    
    /// Parameter is optional.
    public var optional: Bool?
    
    /// Parameter value range for numeric parameters.
    public var range: [Float]?
    
    /// Parameter value choices for enumeration parameters.
    public var enumeration: [EnumerationMember]?
}

/// Prediction parameter enumeration member.
public struct EnumerationMember: Codable {
    
    /// Enumeration member name.
    public var name: String
    
    /// Enumeration member value.
    public var value: EnumerationValue
}

/// Predictor status.
public enum PredictorStatus: String, Codable {
    
    /// Predictor is being compiled.
    case compiling = "COMPILING"
    
    /// Predictor is active.
    case active = "ACTIVE"
    
    /// Predictor is invalid.
    case invalid = "INVALID"
    
    /// Predictor is archived.
    case archived = "ARCHIVED"
}

/// Predictor status.
public enum AccessMode: String, Codable {
    
    /// Predictor is public.
    case Public = "PUBLIC"
    
    /// Predictor is private.
    case Private = "PRIVATE"
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
