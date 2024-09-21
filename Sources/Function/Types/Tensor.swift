//
//  Tensor.swift
//  Function
//
//  Created by Yusuf Olokoba on 10/21/2023.
//  Copyright © 2024 NatML Inc. All rights reserved.
//

import Foundation

public protocol TensorType {}
//extension Float16: TensorType {} // requires Apple Silicon on macOS
extension Float : TensorType {}
extension Double : TensorType {}
extension Int8 : TensorType {}
extension Int16 : TensorType {}
extension Int32 : TensorType {}
extension Int64 : TensorType {}
extension UInt8 : TensorType {}
extension UInt16 : TensorType {}
extension UInt32 : TensorType {}
extension UInt64 : TensorType {}
extension Bool : TensorType {}

/// Prediction value.
public struct Tensor<T : TensorType> {

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
    
    internal func getPointer () -> UnsafePointer<T> {
        if let nativeData = nativeData {
            return nativeData
        } else {
            return data!.withUnsafeBufferPointer { $0.baseAddress! }
        }
    }
}
