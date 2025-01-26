//
//  Predictor.swift
//  Function
//
//  Created by Yusuf Olokoba on 9/28/2024.
//  Copyright © 2025 NatML Inc. All rights reserved.
//

import Function

internal class CPredictor {

    private var predictor: OpaquePointer?

    public init (configuration: Configuration) throws {
        var predictor: OpaquePointer?
        let status = FXNPredictorCreate(configuration.configuration, &predictor)
        if status == FXN_OK {
            self.predictor = predictor!
        } else {
            throw FunctionError.from(status: status)
        }
    }

    public func createPrediction (inputs: ValueMap) throws -> CPrediction {
        var prediction: OpaquePointer?
        let status = FXNPredictorCreatePrediction(predictor, inputs.map, &prediction)
        if status == FXN_OK {
            return CPrediction(prediction: prediction!)
        } else {
            throw FunctionError.from(status: status)
        }
    }

    public func streamPrediction (inputs: ValueMap) throws -> PredictionStream {
        var stream: OpaquePointer?
        let status = FXNPredictorStreamPrediction(predictor, inputs.map, &stream)
        if status == FXN_OK {
            return PredictionStream(stream: stream!)
        } else {
            throw FunctionError.from(status: status)
        }
    }

    public func dispose () {
        if predictor != nil {
            FXNPredictorRelease(predictor)
        }
        self.predictor = nil
    }
}
