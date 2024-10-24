//
//  Prediction.swift
//  Function
//
//  Created by Yusuf Olokoba on 9/28/2024.
//  Copyright © 2024 NatML Inc. All rights reserved.
//

import Function

internal class CPrediction {

    private var prediction: OpaquePointer?

    internal init (prediction: OpaquePointer?) {
        self.prediction = prediction
    }

    public var id: String {
        get {
            var buffer = [CChar](repeating: 0, count: 2048)
            _ = FXNPredictionGetID(prediction, &buffer, Int32(buffer.count))
            return String(cString: buffer)
        }
    }

    public var latency: Double? {
        get {
            var latency = 0.0;
            let status = FXNPredictionGetLatency(prediction, &latency);
            return status == FXN_OK ? latency : nil
        }
    }

    public var results: ValueMap? {
        get {
            var map: OpaquePointer?
            let status = FXNPredictionGetResults(prediction, &map)
            if status != FXN_OK {
                return nil
            }
            var count: Int32 = 0
            FXNValueMapGetSize(map, &count)
            return count > 0 ? ValueMap(map: map) : nil
        }
    }

    public var error: String? {
        get {
            var buffer = [CChar](repeating: 0, count: 2048)
            let status = FXNPredictionGetError(prediction, &buffer, Int32(buffer.count))
            return status == FXN_OK ? String(cString: buffer) : nil
        }
    }

    public var logs: String {
        get {
            var length: Int32 = 0
            FXNPredictionGetLogLength(prediction, &length)
            var buffer = [CChar](repeating: 0, count: Int(length))
            FXNPredictionGetLogs(prediction, &buffer, Int32(buffer.count))
            return String(cString: buffer)
        }
    }

    public func dispose () {
        if prediction != nil {
            FXNPredictionRelease(prediction)
        }
        prediction = nil
    }
}
