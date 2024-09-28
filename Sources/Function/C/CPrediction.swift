//
//  Prediction.swift
//  Function
//
//  Created by Yusuf Olokoba on 9/28/2024.
//  Copyright © 2024 NatML Inc. All rights reserved.
//

import Foundation
import Function

internal class CPrediction { // INCOMPLETE

    private var prediction: OpaquePointer?

    internal init (prediction: OpaquePointer?) {
        self.prediction = prediction
    }

    public func dispose () {
        if prediction != nil {
            FXNPredictionRelease(prediction)
        }
        prediction = nil
    }
}
