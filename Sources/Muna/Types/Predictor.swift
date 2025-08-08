/*
*   Muna
*   Copyright © 2025 NatML Inc. All rights reserved.
*/

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
    public var access: PredictorAccess
    
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
    case compiling = "compiling"
    
    /// Predictor is active.
    case active = "active"
    
    /// Predictor is archived.
    case archived = "archived"
}

/// Predictor status.
public enum PredictorAccess: String, Codable {
    
    /// Predictor is public.
    case `public` = "public"
    
    /// Predictor is private.
    case `private` = "private"
    
    /// Predictor is unlisted.
    case unlisted = "unlisted"
}

/// Prediction parameter enumeration value.
public enum EnumerationValue: Codable {
    
    case string(String)
    case int(Int)

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intValue = try? container.decode(Int.self) {
            self = .int(intValue)
        } else if let stringValue = try? container.decode(String.self) {
            self = .string(stringValue)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid value. Expected either a string or an int.")
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .int(let intValue):
            try container.encode(intValue)
        case .string(let stringValue):
            try container.encode(stringValue)
        }
    }
}
