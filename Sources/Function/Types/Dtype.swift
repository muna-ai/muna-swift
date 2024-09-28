//
//  Dtype.swift
//  Function
//
//  Created by Yusuf Olokoba on 10/21/2023.
//  Copyright © 2024 NatML Inc. All rights reserved.
//

import Foundation

/// Value data type.
public enum Dtype: UInt32, Codable, CustomStringConvertible {

    /// Value is null or has unsupported data type.
    case null = 0
    /// Value is IEEE 754 half precision 16-bit float.
    case float16 = 1
    /// Value is IEEE 754 single precision 32-bit float.
    case float32 = 2
    /// Value is IEEE 754 double precision 64-bit float.
    case float64 = 3
    /// Value is signed 8-bit integer.
    case int8 = 4
    /// Value is signed 16-bit integer.
    case int16 = 5
    /// Value is signed 32-bit integer.
    case int32 = 6
    /// Value is signed 64-bit integer.
    case int64 = 7
    /// Value is unsigned 8-bit integer.
    case uint8 = 8
    /// Value is unsigned 16-bit integer.
    case uint16 = 9
    /// Value is unsigned 32-bit integer.
    case uint32 = 10
    /// Value is unsigned 64-bit integer.
    case uint64 = 11
    /// Value is 8-bit boolean where zero is `false` and non-zero is `true`.
    case bool = 12
    /// Value is a UTF-8 encoded string.
    case string = 13
    /// Value is a JSON-serializable list.
    case list = 14
    /// Value is a JSON-serializable dictionary.
    case dict = 15
    /// Value is a pixel buffer with 8 bits per intensity, interleaved by channel.
    case image = 16
    /// Value is a binary blob.
    case binary = 17

    public var description: String {
        switch self {
            case .null:     return "null"
            case .float16:  return "float16"
            case .float32:  return "float32"
            case .float64:  return "float64"
            case .int8:     return "int8"
            case .int16:    return "int16"
            case .int32:    return "int32"
            case .int64:    return "int64"
            case .uint8:    return "uint8"
            case .uint16:   return "uint16"
            case .uint32:   return "uint32"
            case .uint64:   return "uint64"
            case .bool:     return "bool"
            case .string:   return "string"
            case .list:     return "list"
            case .dict:     return "dict"
            case .image:    return "image"
            case .binary:   return "binary"
        }
    }
    
    public init (from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValue = try container.decode(String.self)
        guard let value = Dtype(stringValue: stringValue) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid string value for Dtype enum: \(stringValue)"
            )
        }
        self = value
    }
    
    public func encode (to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.description)
    }

    private init? (stringValue: String) {
        switch stringValue {
            case "null":    self = .null
            case "float16": self = .float16
            case "float32": self = .float32
            case "float64": self = .float64
            case "int8":    self = .int8
            case "int16":   self = .int16
            case "int32":   self = .int32
            case "int64":   self = .int64
            case "uint8":   self = .uint8
            case "uint16":  self = .uint16
            case "uint32":  self = .uint32
            case "uint64":  self = .uint64
            case "bool":    self = .bool
            case "string":  self = .string
            case "list":    self = .list
            case "dict":    self = .dict
            case "image":   self = .image
            case "binary":  self = .binary
            default:        return nil
        }
    }
}
