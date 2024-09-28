//
//  PredictionStream.swift
//  Function
//
//  Created by Yusuf Olokoba on 9/28/2024.
//  Copyright © 2024 NatML Inc. All rights reserved.
//

import Foundation
import Function

internal class PredictionStream {
    
    private var stream: OpaquePointer?

    internal init (stream: OpaquePointer) {
        self.stream = stream
    }

    public func readNext () -> CPrediction? {
        guard let stream = stream else { return nil }
        var prediction: OpaquePointer?
        let status = FXNPredictionStreamReadNext(stream, &prediction)
        guard let nextPrediction = prediction else { return nil }
        return CPrediction(prediction: nextPrediction)
    }
    
    public func dispose () {
        if stream != nil {
            FXNPredictionStreamRelease(stream)
        }
        stream = nil
    }
}
