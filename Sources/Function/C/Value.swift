//
//  Value.swift
//  Function
//
//  Created by Yusuf Olokoba on 9/28/2024.
//  Copyright © 2024 NatML Inc. All rights reserved.
//

import Accelerate
import CoreVideo
import Function

internal enum ValueFlags: UInt32 {
    case none = 0
    case copyData = 1
}

internal class Value {

    internal var value: OpaquePointer?

    internal init (value: OpaquePointer?) {
        self.value = value
    }

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

    public var shape: [Int]? {
        guard let value = value else { return nil }
        var dimensions: Int32 = 0
        FXNValueGetDimensions(value, &dimensions)
        if dimensions > 0 {
            var shapeArray = [Int32](repeating: 0, count: Int(dimensions))
            let status = FXNValueGetShape(value, &shapeArray, dimensions)
            return status == FXN_OK ? shapeArray.map{ Int($0) } : nil
        }
        return nil
    }

    public func toObject () -> Any? {
        switch type {
        case .null:
            return nil
        case .float16:
            return Value.toTensor(data: data!.assumingMemoryBound(to: Float16.self), shape: shape!)
        case .float32:
            return Value.toTensor(data: data!.assumingMemoryBound(to: Float.self), shape: shape!)
        case .float64:
            return Value.toTensor(data: data!.assumingMemoryBound(to: Double.self), shape: shape!)
        case .int8:
            return Value.toTensor(data: data!.assumingMemoryBound(to: Int8.self), shape: shape!)
        case .int16:
            return Value.toTensor(data: data!.assumingMemoryBound(to: Int16.self), shape: shape!)
        case .int32:
            return Value.toTensor(data: data!.assumingMemoryBound(to: Int32.self), shape: shape!)
        case .int64:
            return Value.toTensor(data: data!.assumingMemoryBound(to: Int64.self), shape: shape!)
        case .uint8:
            return Value.toTensor(data: data!.assumingMemoryBound(to: UInt8.self), shape: shape!)
        case .uint16:
            return Value.toTensor(data: data!.assumingMemoryBound(to: UInt16.self), shape: shape!)
        case .uint32:
            return Value.toTensor(data: data!.assumingMemoryBound(to: UInt32.self), shape: shape!)
        case .uint64:
            return Value.toTensor(data: data!.assumingMemoryBound(to: UInt64.self), shape: shape!)
        case .bool:
            return Value.toTensor(data: data!.assumingMemoryBound(to: Bool.self), shape: shape!)
        case .string:
            return String(cString: data!.assumingMemoryBound(to: CChar.self))
        case .list, .dict:
            let jsonString = String(cString: data!.assumingMemoryBound(to: CChar.self))
            let data = jsonString.data(using: .utf8)!
            let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) as? [Any]
            return jsonObject
        case .image:
            let shape = shape!
            let height = shape[0]
            let width = shape[1]
            let channels = shape[2]
            let pixelFormatType: OSType
            switch channels {
            case 1:
                pixelFormatType = kCVPixelFormatType_OneComponent8
            case 3:
                pixelFormatType = kCVPixelFormatType_24RGB
            case 4:
                pixelFormatType = kCVPixelFormatType_32ARGB
            default:
                return nil
            }
            var pixelBuffer: CVPixelBuffer?
            let attrs: [String: Any] = [ // CHECK // IOSurface??
                kCVPixelBufferMetalCompatibilityKey as String: true,
                kCVPixelBufferCGImageCompatibilityKey as String: true,
                kCVPixelBufferCGBitmapContextCompatibilityKey as String: true,
            ]
            let cvStatus = CVPixelBufferCreate(
                kCFAllocatorDefault,
                width,
                height,
                pixelFormatType,
                attrs as CFDictionary,
                &pixelBuffer
            )
            guard cvStatus == kCVReturnSuccess, let pixelBuffer = pixelBuffer else {
                return nil
            }
            CVPixelBufferLockBaseAddress(pixelBuffer, [])
            defer {
                CVPixelBufferUnlockBaseAddress(pixelBuffer, [])
            }
            guard let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer) else {
                return nil
            }
            var srcBuffer = vImage_Buffer(
                data: UnsafeMutableRawPointer(mutating: data!),
                height: vImagePixelCount(height),
                width: vImagePixelCount(width),
                rowBytes: width * channels
            )
            var dstBuffer = vImage_Buffer(
                data: baseAddress,
                height: vImagePixelCount(height),
                width: vImagePixelCount(width),
                rowBytes: CVPixelBufferGetBytesPerRow(pixelBuffer)
            )
            let vStatus = vImageCopyBuffer(&srcBuffer, &dstBuffer, channels, vImage_Flags(kvImageNoFlags))
            guard vStatus == kvImageNoError else {
                return nil
            }
            return pixelBuffer
        case .binary:
            let count = shape![0]
            let data = Data(bytes: data!, count: Int(count))
            return data
        }
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
            print("Function Error: Failed to create list value because data could not be serialized to JSON")
            return nil
        }
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            print("Function Error: Failed to create list value because data could not be serialized to JSON string")
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
            print("Function Error: Failed to create dictionary value because data could not be serialized to JSON")
            return nil
        }
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            print("Function Error: Failed to create dictionary value because data could not be serialized to JSON string")
            return nil
        }
        return jsonString.withCString { cString in
            var value: OpaquePointer?
            let status = FXNValueCreateDict(cString, &value)
            return status == FXN_OK ? Value(value: value) : nil
        }
    }

    public static func createImage (pixelBuffer: CVPixelBuffer, flags: ValueFlags = .none) -> Value? {
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        defer {
            CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)
        }
        let pixelFormat = CVPixelBufferGetPixelFormatType(pixelBuffer)
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
        guard let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer) else {
            return nil
        }
        let bytesPerPixel: Int
        let channels: Int32
        var zeroCopy = false
        switch pixelFormat {
        case kCVPixelFormatType_OneComponent8:
            bytesPerPixel = 1
            channels = 1
            zeroCopy = true
        case kCVPixelFormatType_24RGB:
            bytesPerPixel = 3
            channels = 3
            zeroCopy = true
        case kCVPixelFormatType_32ARGB:
            bytesPerPixel = 4
            channels = 4
            zeroCopy = true
        default:
            bytesPerPixel = 0
            channels = 0
        }
        let expectedBytesPerRow = bytesPerPixel * width
        zeroCopy = zeroCopy && bytesPerRow == expectedBytesPerRow
        if zeroCopy {
            var value: OpaquePointer?
            let status = FXNValueCreateImage(
                baseAddress.assumingMemoryBound(to: UInt8.self),
                Int32(width),
                Int32(height),
                channels,
                FXNValueFlags(rawValue: flags.rawValue),
                &value
            )
            return status == FXN_OK ? Value(value: value) : nil
        }
        if pixelFormat == kCVPixelFormatType_32BGRA {
            guard let packedBuffer = malloc(width * height * 4) else {
                return nil
            }
            defer {
                free(packedBuffer)
            }
            var srcBuffer = vImage_Buffer(
                data: baseAddress,
                height: vImagePixelCount(height),
                width: vImagePixelCount(width),
                rowBytes: bytesPerRow
            )
            var destBuffer = vImage_Buffer(
                data: packedBuffer,
                height: vImagePixelCount(height),
                width: vImagePixelCount(width),
                rowBytes: width * 4
            )
            let permuteMap: [UInt8] = [2, 1, 0, 3]
            let error = vImagePermuteChannels_ARGB8888(&srcBuffer, &destBuffer, permuteMap, vImage_Flags(kvImageNoFlags))
            if error != kvImageNoError {
                print("Function Error: Failed to create image value because pixel buffer could not be permuted with error: \(error)")
                return nil
            }
            var value: OpaquePointer?
            let status = FXNValueCreateImage(
                baseAddress.assumingMemoryBound(to: UInt8.self),
                Int32(width),
                Int32(height),
                channels,
                FXNValueFlags(rawValue: flags.rawValue | FXN_VALUE_FLAG_COPY_DATA.rawValue),
                &value
            )
            return status == FXN_OK ? Value(value: value) : nil
        }
        print("Function Error: Failed to create image value because pixel value has unsupported format: \(pixelFormat)")
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
    
    private static func toTensor<T: TensorType> (data: UnsafePointer<T>, shape: [Int]) -> Any? {
        if shape.isEmpty {
            return data.pointee
        }
        let buffer = UnsafeBufferPointer(start: data, count: shape.reduce(1, *))
        let data = [T](buffer)
        let tensor = Tensor<T>(data: data, shape: shape)
        return tensor
    }
}
