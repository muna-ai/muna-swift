//
//  ValueMap.swift
//  Function
//
//  Created by Yusuf Olokoba on 9/28/2024.
//  Copyright © 2025 NatML Inc. All rights reserved.
//

import Function

internal class ValueMap {

    internal var map: OpaquePointer?

    internal init () throws {
        var map: OpaquePointer?
        let status = FXNValueMapCreate(&map);
        if status == FXN_OK {
            self.map = map;
        } else {
            throw FunctionError.from(status: status)
        }
    }

    internal init (map: OpaquePointer?) {
        self.map = map
    }

    public var count: Int {
        get throws {
            var count: Int32 = 0
            let status = FXNValueMapGetSize(map, &count)
            if status == FXN_OK {
                return Int(count)
            } else {
                throw FunctionError.from(status: status)
            }
        }
    }

    public func key (at index: Int) throws -> String {
        var buffer = [CChar](repeating: 0, count: 2048)
        let status = FXNValueMapGetKey(map, Int32(index), &buffer, Int32(buffer.count))
        if status == FXN_OK {
            return String(cString: buffer)
        } else {
            throw FunctionError.from(status: status)
        }
    }

    public subscript (key: String) -> Value? {
        get {
            return key.withCString { cKey in
                var value: OpaquePointer?
                let status = FXNValueMapGetValue(map, cKey, &value)
                return status == FXN_OK ? Value(value: value!) : nil
            }
        }
        set {
            key.withCString { cKey in
                _ = FXNValueMapSetValue(map, cKey, newValue?.value)
            }
        }
    }

    public func dispose () {
        if map != nil {
            FXNValueMapRelease(map)
        }
        map = nil
    }
}
