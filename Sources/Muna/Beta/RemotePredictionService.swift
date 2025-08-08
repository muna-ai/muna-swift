/*
*   Muna
*   Copyright © 2025 NatML Inc. All rights reserved.
*/

import CoreGraphics
@preconcurrency import CoreImage
import CoreVideo
import ImageIO

/// Make remote predictions.
public final class RemotePredictionService : Sendable {

    private let client: MunaClient
    private let ciContext: CIContext

    internal init (client: MunaClient) {
        self.client = client
        self.ciContext = CIContext()
    }

    public func create(
        tag: String,
        inputs: [String: Any?],
        acceleration: RemoteAcceleration = .auto
    ) async throws -> Prediction {
        var inputMap = [String: Any]()
        for (key, object) in inputs {
            let value = try await toValue(object, name: key)
            inputMap[key] = value.toDict()
        }
        let prediction: RemotePrediction = try await client.request(
            method: "POST",
            path: "/predictions/remote",
            payload: [
                "tag": tag,
                "inputs": inputMap,
                "acceleration": acceleration.rawValue,
                "clientId": Configuration.clientId
            ]
        )!
        let results: [Any?]?
        if let values = prediction.results {
            var collection = [Any?]()
            for value in values {
                let object = try await toObject(value)
                collection.append(object)
            }
            results = collection
        } else {
            results = nil
        }
        return Prediction(
            id: prediction.id,
            tag: prediction.tag,
            created: prediction.created,
            results: results,
            latency: prediction.latency,
            error: prediction.error,
            logs: prediction.logs
        )
    }

    private func toValue(
        _ value: Any?,
        name: String,
        maxDataUrlSize: Int = 4 * 1024 * 1024
    ) async throws -> RemoteValue {
        switch (value) {
        case nil:
            return RemoteValue(type: .null)
        case let scalar as Float16:
            let tensor = Tensor(data: [scalar], shape: [])
            return try await toValue(tensor, name: name, maxDataUrlSize: maxDataUrlSize)
        case let scalar as Float32:
            let tensor = Tensor(data: [scalar], shape: [])
            return try await toValue(tensor, name: name, maxDataUrlSize: maxDataUrlSize)
        case let scalar as Float64:
            let tensor = Tensor(data: [scalar], shape: [])
            return try await toValue(tensor, name: name, maxDataUrlSize: maxDataUrlSize)
        case let scalar as Int8:
            let tensor = Tensor(data: [scalar], shape: [])
            return try await toValue(tensor, name: name, maxDataUrlSize: maxDataUrlSize)
        case let scalar as Int16:
            let tensor = Tensor(data: [scalar], shape: [])
            return try await toValue(tensor, name: name, maxDataUrlSize: maxDataUrlSize)
        case let scalar as Int32:
            let tensor = Tensor(data: [scalar], shape: [])
            return try await toValue(tensor, name: name, maxDataUrlSize: maxDataUrlSize)
        case let scalar as Int64:
            let tensor = Tensor(data: [scalar], shape: [])
            return try await toValue(tensor, name: name, maxDataUrlSize: maxDataUrlSize)
        case let scalar as UInt8:
            let tensor = Tensor(data: [scalar], shape: [])
            return try await toValue(tensor, name: name, maxDataUrlSize: maxDataUrlSize)
        case let scalar as UInt16:
            let tensor = Tensor(data: [scalar], shape: [])
            return try await toValue(tensor, name: name, maxDataUrlSize: maxDataUrlSize)
        case let scalar as UInt32:
            let tensor = Tensor(data: [scalar], shape: [])
            return try await toValue(tensor, name: name, maxDataUrlSize: maxDataUrlSize)
        case let scalar as UInt64:
            let tensor = Tensor(data: [scalar], shape: [])
            return try await toValue(tensor, name: name, maxDataUrlSize: maxDataUrlSize)
        case let scalar as Int:
            return try await toValue(Int32(scalar), name: name, maxDataUrlSize: maxDataUrlSize)
        case let scalar as Bool:
            let tensor = Tensor(data: [scalar], shape: [])
            return try await toValue(tensor, name: name, maxDataUrlSize: maxDataUrlSize)
        case let array as [Float16]:
            let tensor = Tensor(data: array, shape: [array.count])
            return try await toValue(tensor, name: name, maxDataUrlSize: maxDataUrlSize)
        case let array as [Float32]:
            let tensor = Tensor(data: array, shape: [array.count])
            return try await toValue(tensor, name: name, maxDataUrlSize: maxDataUrlSize)
        case let array as [Float64]:
            let tensor = Tensor(data: array, shape: [array.count])
            return try await toValue(tensor, name: name, maxDataUrlSize: maxDataUrlSize)
        case let array as [Int8]:
            let tensor = Tensor(data: array, shape: [array.count])
            return try await toValue(tensor, name: name, maxDataUrlSize: maxDataUrlSize)
        case let array as [Int16]:
            let tensor = Tensor(data: array, shape: [array.count])
            return try await toValue(tensor, name: name, maxDataUrlSize: maxDataUrlSize)
        case let array as [Int32]:
            let tensor = Tensor(data: array, shape: [array.count])
            return try await toValue(tensor, name: name, maxDataUrlSize: maxDataUrlSize)
        case let array as [Int64]:
            let tensor = Tensor(data: array, shape: [array.count])
            return try await toValue(tensor, name: name, maxDataUrlSize: maxDataUrlSize)
        case let array as [UInt8]:
            let tensor = Tensor(data: array, shape: [array.count])
            return try await toValue(tensor, name: name, maxDataUrlSize: maxDataUrlSize)
        case let array as [UInt16]:
            let tensor = Tensor(data: array, shape: [array.count])
            return try await toValue(tensor, name: name, maxDataUrlSize: maxDataUrlSize)
        case let array as [UInt32]:
            let tensor = Tensor(data: array, shape: [array.count])
            return try await toValue(tensor, name: name, maxDataUrlSize: maxDataUrlSize)
        case let array as [UInt64]:
            let tensor = Tensor(data: array, shape: [array.count])
            return try await toValue(tensor, name: name, maxDataUrlSize: maxDataUrlSize)
        case let array as [Int]:
            return try await toValue(array.map{ Int32($0) }, name: name, maxDataUrlSize: maxDataUrlSize)
        case let array as [Bool]:
            let tensor = Tensor(data: array, shape: [array.count])
            return try await toValue(tensor, name: name, maxDataUrlSize: maxDataUrlSize)
        case let tensor as TensorCompatible:
            let data = try await self.upload(tensor.buffer, name: name, maxDataUrlSize: maxDataUrlSize)
            return RemoteValue(data: data, type: tensor.dtype, shape: tensor.shape)
        case let string as String:
            let buffer = string.data(using: .utf8)!
            let data = try await self.upload(
                buffer,
                name: name,
                mime: "text/plain",
                maxDataUrlSize: maxDataUrlSize
            )
            return RemoteValue(data: data, type: .string)
        case let list as [Any]:
            let buffer = try JSONSerialization.data(withJSONObject: list, options: [])
            let data = try await self.upload(
                buffer,
                name: name,
                mime: "application/json",
                maxDataUrlSize: maxDataUrlSize
            )
            return RemoteValue(data: data, type: .list)
        case let dict as [String: Any]:
            let buffer = try JSONSerialization.data(withJSONObject: dict, options: [])
            let data = try await self.upload(
                buffer,
                name: name,
                mime: "application/json",
                maxDataUrlSize: maxDataUrlSize
            )
            return RemoteValue(data: data, type: .dict)
        case let pixelBuffer as CVPixelBuffer:
            let image = CIImage(cvPixelBuffer: pixelBuffer)
            let buffer = self.ciContext.pngRepresentation(
                of: image,
                format: .RGBA8,
                colorSpace: image.colorSpace!
            )!
            let data = try await self.upload(
                buffer,
                name: name,
                mime: "image/png",
                maxDataUrlSize: maxDataUrlSize
            )
            return RemoteValue(data: data, type: .image)
        case let buffer as Data:
            let data = try await self.upload(buffer, name: name, maxDataUrlSize: maxDataUrlSize)
            return RemoteValue(data: data, type: .binary)
        default:
            throw MunaError.invalidArgument(message: "Failed to serialize value \(String(describing: value)) of type \(type(of: value)) because it is not supported")
        }
    }

    private func toObject(_ value: RemoteValue) async throws -> Any? {
        if value.type == .null {
            return nil
        }
        let data = try await download(value.data!)
        switch value.type {
        case .bfloat16:
            throw MunaError.notImplemented
        case .float16:
            let shape = value.shape!
            let data = data.withUnsafeBytes{ ptr in Array(ptr.bindMemory(to: Float16.self)) }
            return shape.count > 0 ? Tensor(data: data, shape: shape) : data[0];
        case .float32:
            let shape = value.shape!
            let data = data.withUnsafeBytes{ ptr in Array(ptr.bindMemory(to: Float32.self)) }
            return shape.count > 0 ? Tensor(data: data, shape: shape) : data[0];
        case .float64:
            let shape = value.shape!
            let data = data.withUnsafeBytes{ ptr in Array(ptr.bindMemory(to: Float64.self)) }
            return shape.count > 0 ? Tensor(data: data, shape: shape) : data[0];
        case .int8:
            let shape = value.shape!
            let data = data.withUnsafeBytes{ ptr in Array(ptr.bindMemory(to: Int8.self)) }
            return shape.count > 0 ? Tensor(data: data, shape: shape) : data[0];
        case .int16:
            let shape = value.shape!
            let data = data.withUnsafeBytes{ ptr in Array(ptr.bindMemory(to: Int16.self)) }
            return shape.count > 0 ? Tensor(data: data, shape: shape) : data[0];
        case .int32:
            let shape = value.shape!
            let data = data.withUnsafeBytes{ ptr in Array(ptr.bindMemory(to: Int32.self)) }
            return shape.count > 0 ? Tensor(data: data, shape: shape) : data[0];
        case .int64:
            let shape = value.shape!
            let data = data.withUnsafeBytes{ ptr in Array(ptr.bindMemory(to: Int64.self)) }
            return shape.count > 0 ? Tensor(data: data, shape: shape) : data[0];
        case .uint8:
            let shape = value.shape!
            let data = data.withUnsafeBytes{ ptr in Array(ptr.bindMemory(to: UInt8.self)) }
            return shape.count > 0 ? Tensor(data: data, shape: shape) : data[0];
        case .uint16:
            let shape = value.shape!
            let data = data.withUnsafeBytes{ ptr in Array(ptr.bindMemory(to: UInt16.self)) }
            return shape.count > 0 ? Tensor(data: data, shape: shape) : data[0];
        case .uint32:
            let shape = value.shape!
            let data = data.withUnsafeBytes{ ptr in Array(ptr.bindMemory(to: UInt32.self)) }
            return shape.count > 0 ? Tensor(data: data, shape: shape) : data[0];
        case .uint64:
            let shape = value.shape!
            let data = data.withUnsafeBytes{ ptr in Array(ptr.bindMemory(to: UInt64.self)) }
            return shape.count > 0 ? Tensor(data: data, shape: shape) : data[0];
        case .bool:
            let shape = value.shape!
            let data = data.withUnsafeBytes{ ptr in Array(ptr.bindMemory(to: Bool.self)) }
            return shape.count > 0 ? Tensor(data: data, shape: shape) : data[0];
        case .string:
            return String(data: data, encoding: .utf8)
        case .list:
            return try JSONSerialization.jsonObject(with: data, options: []) as? [Any]
        case .dict:
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        case .image:
            guard let source = CGImageSourceCreateWithData(data as CFData, nil),
            let image = CGImageSourceCreateImageAtIndex(source, 0, nil)
            else {
                throw MunaError.invalidArgument(message: "Failed to deserialize image value because image data is invalid")
            }
            let width = image.width
            let height = image.height
            let format = kCVPixelFormatType_32BGRA
            let attrs: [String: Any] = [
                kCVPixelBufferCGImageCompatibilityKey as String: true,
                kCVPixelBufferCGBitmapContextCompatibilityKey as String: true,
                kCVPixelBufferMetalCompatibilityKey as String: true,
            ]
            var pixelBuffer: CVPixelBuffer?
            guard CVPixelBufferCreate(
                kCFAllocatorDefault,
                width,
                height,
                format,
                attrs as CFDictionary,
                &pixelBuffer
            ) == kCVReturnSuccess, let buffer = pixelBuffer
            else {
                throw MunaError.invalidArgument(message: "Failed to deserialize image value because pixel buffer could not be created")
            }
            CVPixelBufferLockBaseAddress(buffer, [])
            defer { CVPixelBufferUnlockBaseAddress(buffer, []) }
            guard let context = CGContext(
                data: CVPixelBufferGetBaseAddress(buffer),
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
            ) else {
                throw MunaError.invalidArgument(message: "Failed to deserialize image value because image context could not be created")
            }
            let rect = CGRect(x: 0, y: 0, width: width, height: height)
            context.draw(image, in: rect)
            return pixelBuffer
        case .binary:
            return data
        case .null:
            return nil
        }
    }

    private func upload(
        _ data: Data,
        name: String,
        mime: String = "application/octet-stream",
        maxDataUrlSize: Int
    ) async throws -> String {
        if data.count <= maxDataUrlSize {
            return "data:\(mime);base64,\(data.base64EncodedString())"
        }
        let value: CreateValueResponse = try! await client.request(
            method: "POST",
            path: "/values",
            payload: [ "name": name ]
        )!
        let uploadUrl = URL(string: value.uploadUrl)!
        var request = URLRequest(url: uploadUrl)
        request.httpMethod = "PUT"
        request.addValue(mime, forHTTPHeaderField: "Content-Type")
        let (_, response) = try await URLSession.shared.upload(for: request, from: data)
        if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
            throw MunaError.requestFailed(message: "Failed to upload value", status: httpResponse.statusCode)
        }
        return value.downloadUrl
    }

    private func download(_ url: String) async throws -> Data {
        if url.hasPrefix("data:") {
            guard let commaIdx = url.firstIndex(of: ",") else {
                throw MunaError.invalidArgument(message: "Failed to deserialize value because data URL scheme is invalid")
            }
            let encodedData = String(url[url.index(after: commaIdx)...])
            guard let decoded = Data(base64Encoded: encodedData) else {
                throw MunaError.invalidArgument(message: "Failed to deserialize value because data URL is invalid")
            }
            return decoded
        } else {
            guard let remoteUrl = URL(string: url) else {
                throw MunaError.invalidArgument(message: "Failed to deserialize value because URL is invalid")
            }
            let (data, _) = try await URLSession.shared.data(from: remoteUrl)
            return data
        }
    }
}

/// Remote prediction  acceleration.
public enum RemoteAcceleration: String, Codable {

    /// Automatically choose the best acceleration for the predictor.
    case auto = "remote_auto"

    /// Predictions run on a CPU instance.
    case cpu = "remote_cpu"

    /// Predictions run on an Nvidia A40 GPU instance.
    case a40 = "remote_a40"

    /// Predictions run on an Nvidia A100 GPU instance.
    case a100 = "remote_a100"
}

private struct RemoteValue: Codable {

    public var data: String?
    public var type: Dtype
    public var shape: [Int]?
    
    public init(data: String? = nil, type: Dtype, shape: [Int]? = nil) {
        self.data = data
        self.type = type
        self.shape = shape
    }
    
    public func toDict() -> [String: Any] {
        return [
            "data": self.data as Any,
            "type": self.type.description as Any,
            "shape": self.shape as Any
        ]
    }
}

private struct RemotePrediction: Codable {
    var id: String
    var tag: String
    var created: Date
    var results: [RemoteValue]?
    var latency: Double?
    var error: String?
    var logs: String?
}

private struct CreateValueResponse: Codable {
    var uploadUrl: String
    var downloadUrl: String
}
