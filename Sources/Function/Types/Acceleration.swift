//
//  Acceleration.swift
//  Function
//
//  Created by Yusuf Olokoba on 10/21/2023.
//  Copyright © 2023 NatML Inc. All rights reserved.
//

import Foundation

/// Predictor acceleration.
public enum Acceleration: Int, Codable {
    
    /// Predictions run on the CPU.
    case CPU = 0
    
    /// Predictions run on an Nvidia A40 GPU.
    case A40 = 1
    
    /// Predictions run on an Nvidia A100 GPU.
    case A100 = 2
    
    public var stringValue: String {
        switch self {
            case .CPU: return "CPU"
            case .A40: return "A40"
            case .A100: return "A100"
        }
    }
    
    public init? (stringValue: String) {
        switch stringValue {
            case "CPU": self = .CPU
            case "A40": self = .A40
            case "A100": self = .A100
            default: return nil
        }
    }
    
    public init (from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValue = try container.decode(String.self)
        guard let value = Acceleration(stringValue: stringValue) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid string value for Acceleration enum: \(stringValue)")
        }
        self = value
    }
    
    public func encode (to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(stringValue)
    }
}
