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

    internal init (value: OpaquePointer) {
        self.value = value
    }

    public var data: UnsafeRawPointer? {
        get throws {
            var dataPointer: UnsafeMutableRawPointer?
            let status = FXNValueGetData(value, &dataPointer)
            if status == FXN_OK {
                return UnsafeRawPointer(dataPointer)
            } else {
                throw FunctionError.from(status: status)
            }
        }
    }

    public var type: Dtype {
        get throws {
            var dtype: FXNDtype = FXN_DTYPE_NULL;
            let status = FXNValueGetType(value, &dtype)
            if status == FXN_OK {
                return Dtype(rawValue: dtype.rawValue)!
            } else {
                throw FunctionError.from(status: status)
            }
        }
    }

    public var shape: [Int] {
        get throws {
            var dimensions: Int32 = 0
            var status = FXNValueGetDimensions(value, &dimensions)
            if status != FXN_OK {
                throw FunctionError.from(status: status)
            }
            if dimensions == 0 {
                return []
            }
            var shapeArray = [Int32](repeating: 0, count: Int(dimensions))
            status = FXNValueGetShape(value, &shapeArray, dimensions)
            if status == FXN_OK {
                return shapeArray.map{ Int($0) }
            } else {
                throw FunctionError.from(status: status)
            }
        }
    }

    public func toObject () throws -> Any? {
        switch try type {
        case .null:
            return nil
        case .float16:
            return Value.toTensor(data: try data!.assumingMemoryBound(to: Float16.self), shape: try shape)
        case .float32:
            return Value.toTensor(data: try data!.assumingMemoryBound(to: Float.self), shape: try shape)
        case .float64:
            return Value.toTensor(data: try data!.assumingMemoryBound(to: Double.self), shape: try shape)
        case .int8:
            return Value.toTensor(data: try data!.assumingMemoryBound(to: Int8.self), shape: try shape)
        case .int16:
            return Value.toTensor(data: try data!.assumingMemoryBound(to: Int16.self), shape: try shape)
        case .int32:
            return Value.toTensor(data: try data!.assumingMemoryBound(to: Int32.self), shape: try shape)
        case .int64:
            return Value.toTensor(data: try data!.assumingMemoryBound(to: Int64.self), shape: try shape)
        case .uint8:
            return Value.toTensor(data: try data!.assumingMemoryBound(to: UInt8.self), shape: try shape)
        case .uint16:
            return Value.toTensor(data: try data!.assumingMemoryBound(to: UInt16.self), shape: try shape)
        case .uint32:
            return Value.toTensor(data: try data!.assumingMemoryBound(to: UInt32.self), shape: try shape)
        case .uint64:
            return Value.toTensor(data: try data!.assumingMemoryBound(to: UInt64.self), shape: try shape)
        case .bool:
            return Value.toTensor(data: try data!.assumingMemoryBound(to: Bool.self), shape: try shape)
        case .string:
            return String(cString: try data!.assumingMemoryBound(to: CChar.self))
        case .list, .dict:
            let jsonString = String(cString: try data!.assumingMemoryBound(to: CChar.self))
            let data = jsonString.data(using: .utf8)!
            let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) as? [Any]
            return jsonObject
        case .image:
            let shape = try shape
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
                data: UnsafeMutableRawPointer(mutating: try data!),
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
            let count = try shape[0]
            let data = Data(bytes: try data!, count: Int(count))
            return data
        }
    }

    public func dispose () {
        if value != nil {
            FXNValueRelease(value)
        }
        value = nil
    }
    
    public static func createArray<T> (data: Tensor<T>, flags: ValueFlags = .none) throws -> Value {
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
        if status == FXN_OK {
            return Value(value: value!)
        } else {
            throw FunctionError.from(status: status)
        }
    }

    public static func createString (data: String) throws -> Value {
        return try data.withCString { cString in
            var value: OpaquePointer?
            let status = FXNValueCreateList(cString, &value)
            if status == FXN_OK {
                return Value(value: value!)
            } else {
                throw FunctionError.from(status: status)
            }
        }
    }

    public static func createList (data: [Any]) throws -> Value {
        let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
        let jsonString = String(data: jsonData, encoding: .utf8)!
        return try jsonString.withCString { cString in
            var value: OpaquePointer?
            let status = FXNValueCreateList(cString, &value)
            if status == FXN_OK {
                return Value(value: value!)
            } else {
                throw FunctionError.from(status: status)
            }
        }
    }

    public static func createDict (data: [String: Any]) throws -> Value {
        let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
        let jsonString = String(data: jsonData, encoding: .utf8)!
        return try jsonString.withCString { cString in
            var value: OpaquePointer?
            let status = FXNValueCreateDict(cString, &value)
            if status == FXN_OK {
                return Value(value: value!)
            } else {
                throw FunctionError.from(status: status)
            }
        }
    }

    public static func createImage (pixelBuffer: CVPixelBuffer, flags: ValueFlags = .none) throws -> Value {
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        defer {
            CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)
        }
        let pixelFormat = CVPixelBufferGetPixelFormatType(pixelBuffer)
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
        let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer)!
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
            if status == FXN_OK {
                return Value(value: value!)
            } else {
                throw FunctionError.from(status: status)
            }
        }
        if pixelFormat == kCVPixelFormatType_32BGRA {
            let packedBuffer = malloc(width * height * 4)!
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
                throw FunctionError.invalidOperation(message: "Pixel buffer could not be permuted to `RGBA8888` with error: \(error)")
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
            if status == FXN_OK {
                return Value(value: value!)
            } else {
                throw FunctionError.from(status: status)
            }
        }
        throw FunctionError.invalidArgument(message: "Pixel buffer has unsupported format: \(pixelFormat)")
    }

    public static func createBinary (buffer: Data, flags: ValueFlags = .none) throws -> Value {
        return try buffer.withUnsafeBytes { rawBufferPointer in
            let bufferPtr = rawBufferPointer.baseAddress
            let data = UnsafeMutableRawPointer(mutating: bufferPtr)
            var value: OpaquePointer?
            let status = FXNValueCreateBinary(
                data,
                Int32(buffer.count),
                FXNValueFlags(UInt32(flags.rawValue)),
                &value
            );
            if status == FXN_OK {
                return Value(value: value!)
            } else {
                throw FunctionError.from(status: status)
            }
        }
    }

    public static func createNull () throws -> Value {
        var value: OpaquePointer?
        let status = FXNValueCreateNull(&value)
        if status == FXN_OK {
            return Value(value: value!)
        } else {
            throw FunctionError.from(status: status)
        }
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
