//
//  Value.swift
//  Function
//
//  Created by Yusuf Olokoba on 9/28/2024.
//  Copyright © 2024 NatML Inc. All rights reserved.
//

import CoreVideo
import Foundation
import Function

internal enum ValueFlags: UInt32 {
    case none = 0
    case copyData = 1
}

internal class Value {

    private var value: OpaquePointer?
    
    public var data: UnsafeRawPointer? {
        guard let value = value else { return nil }
        var dataPointer: UnsafeMutableRawPointer?
        let status = FXNValueGetData(value, &dataPointer)
        return status == FXN_OK ? UnsafeRawPointer(dataPointer) : nil
    }

    public var type: Dtype {
        guard let value = value else { return .null }
        var dtype: FXNDtype = FXN_DTYPE_NULL;
        let status = FXNValueGetType(value, &dtype)
        return status == FXN_OK ? Dtype(rawValue: dtype.rawValue)! : .null;
    }

    public var shape: [Int32]? {
        guard let value = value else { return nil }
        var dimensions: Int32 = 0
        FXNValueGetDimensions(value, &dimensions)
        if dimensions > 0 {
            var shapeArray = [Int32](repeating: 0, count: Int(dimensions))
            FXNValueGetShape(value, &shapeArray, dimensions)
            return shapeArray
        }
        return nil
    }

    public func toObject () -> Any? { // INCOMPLETE
        return nil
    }

    public func dispose () {
        if value != nil {
            FXNValueRelease(value)
        }
        value = nil
    }
    
    public static func createArray<T> (data: Tensor<T>, flags: ValueFlags = .none) -> Value? {
        var value: OpaquePointer?
        let dtype = FXNDtype(rawValue: data.dataType.rawValue)
        let shape = data.shape.map { Int32($0) }
        let status = FXNValueCreateArray(
            UnsafeMutableRawPointer(mutating: data.dataPointer),
            shape,
            Int32(data.shape.count),
            dtype,
            FXNValueFlags(rawValue: flags.rawValue),
            &value
        );
        return status == FXN_OK ? Value(value: value) : nil
    }

    public static func createString (data: String) -> Value? {
        return data.withCString { cString in
            var value: OpaquePointer?
            let status = FXNValueCreateList(cString, &value)
            return status == FXN_OK ? Value(value: value) : nil
        }
    }

    public static func createList (data: [Any]) -> Value? {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: data, options: []) else {
            print("Function Error: Cannot create list value because data could not be serialized to JSON")
            return nil
        }
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            print("Function Error: Cannot create list value because data could not be serialized to JSON string")
            return nil
        }
        return jsonString.withCString { cString in
            var value: OpaquePointer?
            let status = FXNValueCreateList(cString, &value)
            return status == FXN_OK ? Value(value: value) : nil
        }
    }

    public static func createDict (data: [String: Any]) -> Value? {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: data, options: []) else {
            print("Function Error: Cannot create dictionary value because data could not be serialized to JSON")
            return nil
        }
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            print("Function Error: Cannot create dictionary value because data could not be serialized to JSON string")
            return nil
        }
        return jsonString.withCString { cString in
            var value: OpaquePointer?
            let status = FXNValueCreateDict(cString, &value)
            return status == FXN_OK ? Value(value: value) : nil
        }
    }

    public static func createImage (pixelBuffer: CVPixelBuffer, flags: ValueFlags = .none) -> Value? { // INCOMPLETE
        return nil
    }

    public static func createBinary (buffer: Data, flags: ValueFlags = .none) -> Value? {
        return buffer.withUnsafeBytes { rawBufferPointer in
            guard let bufferPtr = rawBufferPointer.baseAddress else { return nil }
            let data = UnsafeMutableRawPointer(mutating: bufferPtr)
            var value: OpaquePointer?
            let status = FXNValueCreateBinary(
                data,
                Int32(buffer.count),
                FXNValueFlags(UInt32(flags.rawValue)),
                &value
            );
            return status == FXN_OK ? Value(value: value) : nil
        }
    }

    public static func createNull () -> Value? {
        var value: OpaquePointer?
        FXNValueCreateNull(&value)
        return Value(value: value)
    }

    internal init (value: OpaquePointer?) {
        self.value = value
    }
}
