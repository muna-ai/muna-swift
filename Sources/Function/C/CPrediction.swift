//
//  Prediction.swift
//  Function
//
//  Created by Yusuf Olokoba on 9/28/2024.
//  Copyright © 2025 NatML Inc. All rights reserved.
//

import Function

internal class CPrediction {

    private var prediction: OpaquePointer?

    internal init (prediction: OpaquePointer) {
        self.prediction = prediction
    }

    public var id: String {
        get throws {
            var buffer = [CChar](repeating: 0, count: 2048)
            let status = FXNPredictionGetID(prediction, &buffer, Int32(buffer.count))
            if status == FXN_OK {
                return String(cString: buffer)
            } else {
                throw FunctionError.from(status: status)
            }
        }
    }

    public var latency: Double {
        get throws {
            var latency = 0.0;
            let status = FXNPredictionGetLatency(prediction, &latency);
            if status == FXN_OK {
                return latency
            } else {
                throw FunctionError.from(status: status)
            }
        }
    }

    public var results: ValueMap? {
        get throws {
            var map: OpaquePointer?
            var status = FXNPredictionGetResults(prediction, &map)
            if status != FXN_OK {
                throw FunctionError.from(status: status)
            }
            var count: Int32 = 0
            status = FXNValueMapGetSize(map, &count)
            if status != FXN_OK {
                throw FunctionError.from(status: status)
            }
            return count > 0 ? ValueMap(map: map) : nil
        }
    }

    public var error: String? {
        get throws {
            var buffer = [CChar](repeating: 0, count: 2048)
            let status = FXNPredictionGetError(prediction, &buffer, Int32(buffer.count))
            if status == FXN_ERROR_INVALID_OPERATION {
                return nil
            }
            if status == FXN_OK {
                return String(cString: buffer)
            } else {
                throw FunctionError.from(status: status)
            }
        }
    }

    public var logs: String {
        get throws {
            var length: Int32 = 0
            var status = FXNPredictionGetLogLength(prediction, &length)
            if status != FXN_OK {
                throw FunctionError.from(status: status)
            }
            var buffer = [CChar](repeating: 0, count: Int(length) + 1)
            status = FXNPredictionGetLogs(prediction, &buffer, Int32(buffer.count))
            if status == FXN_OK {
                return String(cString: buffer)
            } else {
                throw FunctionError.from(status: status)
            }
        }
    }

    public func dispose () {
        if prediction != nil {
            FXNPredictionRelease(prediction)
        }
        prediction = nil
    }
}
