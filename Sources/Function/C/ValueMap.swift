//
//  ValueMap.swift
//  Function
//
//  Created by Yusuf Olokoba on 9/28/2024.
//  Copyright © 2024 NatML Inc. All rights reserved.
//

import Function

internal class ValueMap {

    internal var map: OpaquePointer?

    internal init () {
        var map: OpaquePointer?
        _ = FXNValueMapCreate(&map);
        self.map = map;
    }

    internal init (map: OpaquePointer?) {
        self.map = map
    }

    public var count: Int {
        get {
            var count: Int32 = 0
            FXNValueMapGetSize(map, &count)
            return Int(count)
        }
    }

    public func key (at index: Int) -> String? {
        var buffer = [CChar](repeating: 0, count: 2048)
        let status = FXNValueMapGetKey(map, Int32(index), &buffer, Int32(buffer.count))
        return status == FXN_OK ? String(cString: buffer) : nil
    }

    public subscript (key: String) -> Value? {
        get {
            return key.withCString { cKey in
                var value: OpaquePointer?
                let status = FXNValueMapGetValue(map, cKey, &value)
                return status == FXN_OK ? Value(value: value) : nil
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
