/*
*   Muna
*   Copyright © 2025 NatML Inc. All rights reserved.
*/

import Function

internal class PredictionStream {

    private var stream: OpaquePointer?

    internal init(stream: OpaquePointer) {
        self.stream = stream
    }

    public func readNext() throws -> CPrediction? {
        var prediction: OpaquePointer?
        let status = FXNPredictionStreamReadNext(stream, &prediction)
        if status == FXN_ERROR_INVALID_OPERATION {
            return nil
        }
        if status == FXN_OK {
            return CPrediction(prediction: prediction!)
        } else {
            throw MunaError.from(status: status)
        }
    }

    public func dispose() {
        if stream != nil {
            FXNPredictionStreamRelease(stream)
        }
        stream = nil
    }
}
