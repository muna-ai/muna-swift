//
//  Predictor.swift
//  Function
//
//  Created by Yusuf Olokoba on 10/21/2023.
//  Copyright © 2024 NatML Inc. All rights reserved.
//

import Foundation

/// Prediction function.
public struct Predictor : Codable {
    
    /// Predictor tag.
    var tag: String
    
    /// Predictor owner.
    var owner: User
    
    /// Predictor name.
    var name: String

    /// Predictor access.
    var access: AccessMode
    
    /// Predictor status.
    var status: PredictorStatus
    
    /// Date created.
    var created: Date
    
    /// Predictor description.
    var description: String?
    
    /// Predictor card.
    var card: String?
    
    /// Predictor media URL.
    var media: String?
    
    /// Predictor signature.
    var signature: Signature?
    
    /// Predictor provisioning error.
    /// This is populated when the predictor status is `INVALID`.
    var error: String?
    
    /// Predictor license URL.
    var license: String?
}

/// Predictor signature.
public struct Signature : Codable {
    
    /// Prediction inputs.
    var inputs: [Parameter]
    
    /// Prediction outputs.
    var outputs: [Parameter]
}

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
    var defaultValue: Any? // INCOMPLETE
    
    private enum CodingKeys: String, CodingKey {
        case name, type, description, optional, range, enumeration
    }
}

/// Prediction parameter enumeration member.
public struct EnumerationMember: Codable {
    
    /// Enumeration member name.
    var name: String
    
    /// Enumeration member value.
    var value: EnumerationValue
}

/// Predictor status.
public enum PredictorStatus : String, Codable {
    
    /// Predictor is being provisioned.
    case Provisioning = "PROVISIONING"
    
    /// Predictor is active.
    case Active = "ACTIVE"
    
    /// Predictor is invalid.
    case Invalid = "INVALID"
    
    /// Predictor is archived.
    case Archived = "ARCHIVED"
}

/// Predictor status.
public enum AccessMode : String, Codable {
    
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
