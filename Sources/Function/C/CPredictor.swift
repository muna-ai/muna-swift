//
//  Predictor.swift
//  Function
//
//  Created by Yusuf Olokoba on 9/28/2024.
//  Copyright © 2024 NatML Inc. All rights reserved.
//

import Foundation
import Function

internal class CPredictor {
    
    private var predictor: OpaquePointer?
    
    public init (configuration: Configuration) {
        var predictor: OpaquePointer?
        let status = FXNPredictorCreate(configuration.configuration, &predictor)
        self.predictor = status == FXN_OK ? predictor : nil
    }
    
    public func createPrediction (inputs: ValueMap) -> CPrediction? {
        guard let predictor = predictor else { return nil }
        var prediction: OpaquePointer?
        let status = FXNPredictorCreatePrediction(predictor, inputs.map, &prediction)
        guard status == FXN_OK, let validPrediction = prediction else { return nil }
        return CPrediction(prediction: validPrediction)
    }
    
    public func streamPrediction (inputs: ValueMap) -> PredictionStream? {
        guard let predictor = predictor else { return nil }
        var stream: OpaquePointer?
        let status = FXNPredictorStreamPrediction(predictor, inputs.map, &stream)
        guard status == FXN_OK, let validStream = stream else { return nil }
        return PredictionStream(stream: validStream)
    }
    
    public func dispose () {
        if predictor != nil {
            FXNPredictorRelease(predictor)
        }
        self.predictor = nil
    }
}
