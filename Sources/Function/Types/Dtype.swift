//
//  Dtype.swift
//  Function
//
//  Created by Yusuf Olokoba on 10/21/2023.
//  Copyright © 2023 NatML Inc. All rights reserved.
//

import Foundation

/// Value type.
/// This follows `numpy` dtypes.
public enum Dtype: Int, Codable {

    /// Null or unsupported data type.
    case null = 0
    /// Type is a `int8_t` in C/C++.
    case int8 = 10
    /// Type is `int16_t` in C/C++.
    case int16 = 2
    /// Type is `int32_t` in C/C++.
    case int32 = 3
    /// Type is `int64_t` in C/C++.
    case int64 = 4
    /// Type is `uint8_t` in C/C++.
    case uint8 = 1
    /// Type is a `uint16_t` in C/C++.
    case uint16 = 11
    /// Type is a `uint32_t` in C/C++.
    case uint32 = 12
    /// Type is a `uint64_t` in C/C++.
    case uint64 = 13
    /// Type is a generic half-precision float.
    case float16 = 14
    /// Type is `float` in C/C++.
    case float32 = 5
    /// Type is `double` in C/C++.
    case float64 = 6
    /// Type is a `bool` in C/C++.
    case bool = 15
    /// Type is `std::string` in C++.
    case string = 7
    /// Type is an encoded image.
    case image = 16
    /// Type is an encoded audio.
    case audio = 18
    /// Type is an encoded video.
    case video = 19
    /// Type is a binary blob.
    case binary = 17
    /// Type is a generic list.
    case list = 8
    /// Type is a generic dictionary.
    case dict = 9
    
    public var stringValue: String {
        switch self {
            case .null: return "null"
            case .int8: return "int8"
            case .int16: return "int16"
            case .int32: return "int32"
            case .int64: return "int64"
            case .uint8: return "uint8"
            case .uint16: return "uint16"
            case .uint32: return "uint32"
            case .uint64: return "uint64"
            case .float16: return "float16"
            case .float32: return "float32"
            case .float64: return "float64"
            case .bool: return "bool"
            case .string: return "string"
            case .image: return "image"
            case .audio: return "audio"
            case .video: return "video"
            case .binary: return "binary"
            case .list: return "list"
            case .dict: return "dict"
        }
    }
    
    public init? (stringValue: String) {
        switch stringValue {
            case "null": self = .null
            case "int8": self = .int8
            case "int16": self = .int16
            case "int32": self = .int32
            case "int64": self = .int64
            case "uint8": self = .uint8
            case "uint16": self = .uint16
            case "uint32": self = .uint32
            case "uint64": self = .uint64
            case "float16": self = .float16
            case "float32": self = .float32
            case "float64": self = .float64
            case "bool": self = .bool
            case "string": self = .string
            case "image": self = .image
            case "audio": self = .audio
            case "video": self = .video
            case "binary": self = .binary
            case "list": self = .list
            case "dict": self = .dict
            default: return nil
        }
    }
    
    public init (from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValue = try container.decode(String.self)
        guard let value = Dtype(stringValue: stringValue) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid string value for Dtype enum: \(stringValue)")
        }
        self = value
    }
    
    public func encode (to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.stringValue)
    }
}
