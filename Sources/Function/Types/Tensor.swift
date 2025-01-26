//
//  Tensor.swift
//  Function
//
//  Created by Yusuf Olokoba on 10/21/2023.
//  Copyright © 2025 NatML Inc. All rights reserved.
//

import Foundation

public protocol TensorType {}
extension Float16: TensorType {}
extension Float32 : TensorType {}
extension Float64 : TensorType {}
extension Int8 : TensorType {}
extension Int16 : TensorType {}
extension Int32 : TensorType {}
extension Int64 : TensorType {}
extension UInt8 : TensorType {}
extension UInt16 : TensorType {}
extension UInt32 : TensorType {}
extension UInt64 : TensorType {}
extension Bool : TensorType {}

internal protocol TensorCompatible {
    var dtype: Dtype { get }
    var pointer: UnsafeRawPointer { get }
    var buffer: Data { get }
    var shape: [Int] { get }
}

/// Prediction value.
public struct Tensor<T : TensorType> : TensorCompatible {

    /// Tensor data.
    public let data: [T]?

    /// Tensor shape.
    public let shape: [Int]

    private let nativeData: UnsafePointer<T>?

    /// Create a tensor.
    /// - Parameters:
    ///   - data: Tensor data.
    ///   - shape: Tensor shape.
    public init (data: [T], shape: [Int]) {
        self.data = data
        self.nativeData = nil
        self.shape = shape
    }

    /// Create a tensor.
    /// - Parameters:
    ///   - data: Pointer to tensor data.
    ///   - shape: Tensor shape.
    public init (data: UnsafePointer<T>, shape: [Int]) {
        self.data = nil
        self.nativeData = data
        self.shape = shape
    }
    
    internal var dtype: Dtype {
        switch T.self {
        case is Float16.Type:   return .float16
        case is Float.Type:     return .float32
        case is Double.Type:    return .float64
        case is Int8.Type:      return .int8
        case is Int16.Type:     return .int16
        case is Int32.Type:     return .int32
        case is Int64.Type:     return .int64
        case is UInt8.Type:     return .uint8
        case is UInt16.Type:    return .uint16
        case is UInt32.Type:    return .uint32
        case is UInt64.Type:    return .uint64
        case is Bool.Type:      return .bool
        default:                return .null
        }
    }

    internal var pointer: UnsafeRawPointer {
        if let nativeData = nativeData {
            return UnsafeRawPointer(nativeData)
        } else {
            return data!.withUnsafeBufferPointer { UnsafeRawPointer($0.baseAddress!) }
        }
    }
    
    internal var buffer: Data {
        let elementCount = shape.reduce(1, *)
        if let nativeData = nativeData {
            return Data(bytes: nativeData, count: elementCount * MemoryLayout<T>.size)
        }
        return data!.withUnsafeBufferPointer {
            Data(buffer: $0)
        }
    }
}
