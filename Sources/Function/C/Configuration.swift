//
//  Configuration.swift
//  Function
//
//  Created by Yusuf Olokoba on 9/28/2024.
//  Copyright © 2024 NatML Inc. All rights reserved.
//

import Foundation
import Function
import Metal

public class Configuration {

    internal var configuration: OpaquePointer?
    
    public init () {
        var configuration: OpaquePointer?
        let status = FXNConfigurationCreate(&configuration);
        self.configuration = configuration;
    }

    public var tag: String? {
        get {
            var buffer = [CChar](repeating: 0, count: 2048)
            let status = FXNConfigurationGetTag(configuration, &buffer, Int32(buffer.count))
            return status == FXN_OK ? String(cString: buffer) : nil
        }
        set {
            if let tagValue = newValue {
                tagValue.withCString { cString in
                    _ = FXNConfigurationSetTag(configuration, cString)
                }
            } else {
                FXNConfigurationSetTag(configuration, nil)
            }
        }
    }

    public var token: String? {
        get {
            var buffer = [CChar](repeating: 0, count: 2048)
            let status = FXNConfigurationGetToken(configuration, &buffer, Int32(buffer.count))
            return status == FXN_OK ? String(cString: buffer) : nil
        }
        set {
            if let tokenValue = newValue {
                tokenValue.withCString { cString in
                    _ = FXNConfigurationSetToken(configuration, cString)
                }
            } else {
                FXNConfigurationSetToken(configuration, nil)
            }
        }
    }

    public var acceleration: Acceleration {
        get {
            var accel: FXNAcceleration = FXN_ACCELERATION_DEFAULT
            let status = FXNConfigurationGetAcceleration(configuration, &accel)
            return status == FXN_OK ? Acceleration(rawValue: accel.rawValue)! : .auto
        }
        set {
            _ = FXNConfigurationSetAcceleration(configuration, FXNAcceleration(newValue.rawValue))
        }
    }

    public var device: MTLDevice? {
        get {
            var devicePtr: UnsafeMutableRawPointer?
            _ = FXNConfigurationGetDevice(configuration, &devicePtr)
            if let validDevicePtr = devicePtr {
                return Unmanaged<MTLDevice>.fromOpaque(validDevicePtr).takeUnretainedValue()
            } else {
                return nil;
            }
        }
        set {
            if let deviceValue = newValue {
                let devicePtr = Unmanaged.passUnretained(deviceValue).toOpaque()
                _ = FXNConfigurationSetDevice(configuration, devicePtr);
            } else {
                _ = FXNConfigurationSetDevice(configuration, nil);
            }
        }
    }

    public func addResource (type: String, path: String) throws {
        type.withCString { typeCString in
            path.withCString { pathCString in
                _ = FXNConfigurationAddResource(configuration, typeCString, pathCString)
            }
        }
    }

    public func dispose () {
        if configuration != nil {
            FXNConfigurationRelease(configuration)
        }
        configuration = nil
    }

    public static var uniqueId: String? {
        var buffer = [CChar](repeating: 0, count: 2048)
        let status = FXNConfigurationGetUniqueID(&buffer, Int32(buffer.count))
        return status == FXN_OK ? String(cString: buffer) : nil
    }

    public static var clientId: String? {
        var buffer = [CChar](repeating: 0, count: 64)
        let status = FXNConfigurationGetClientID(&buffer, Int32(buffer.count))
        return status == FXN_OK ? String(cString: buffer) : nil
    }
}
