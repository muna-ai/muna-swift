//
//  PredictionService.swift
//  Function
//
//  Created by Yusuf Olokoba on 9/21/2024.
//  Copyright © 2024 NatML Inc. All rights reserved.
//

import Foundation
import Function
import Metal

public class PredictionService { // INCOMPLETE

    private let client: FunctionClient
    private var cache: [String: CPredictor]
    private static let predictionCache: [String: Prediction] = {
        guard let url = Bundle.main.url(forResource: "fxn.resolved", withExtension: "json") else {
            return [:]
        }
        guard let data = try? Data(contentsOf: url) else {
            return [:]
        }
        let decoder = JSONDecoder()
        decoder.allowsJSON5 = true
        decoder.dateDecodingStrategy = .formatted(DateFormatter.utcFormatter)
        guard let configuration = try? decoder.decode(ResolvedConfiguration.self, from: data) else {
            return [:]
        }
        let cache = Dictionary(uniqueKeysWithValues: configuration.predictions.map { ($0.tag, $0) })
        return cache
    }()

    internal init (client: FunctionClient) {
        self.client = client
        self.cache = [:]
    }

    public func create (
        tag: String,
        inputs: [String: Any?]? = nil,
        acceleration: Acceleration = .auto,
        device: MTLDevice? = nil,
        clientId: String? = nil,
        configurationId: String? = nil
    ) async throws -> Prediction {
        guard let inputs = inputs else {
            return try await createRawPrediction(
                tag: tag,
                clientId: clientId,
                configurationId: configurationId
            )
        }
        let predictor = try await getPredictor(
            tag: tag,
            acceleration: acceleration,
            device: device,
            clientId: clientId,
            configurationId: configurationId
        )
        let inputMap = toValueMap(inputs: inputs)
        defer { inputMap.dispose() }
        let prediction = predictor.createPrediction(inputs: inputMap)
        defer { prediction?.dispose() }
        return toPrediction(tag: tag, prediction: prediction)
    }

    public func stream (
        tag: String,
        inputs: [String: Any],
        acceleration: Acceleration = .auto,
        device: UnsafeRawPointer? = nil
    ) async throws -> AsyncStream<Prediction> {
        return AsyncStream { continuation in
            continuation.finish()
        }
    }
    
    public func delete (tag: String) async throws -> Bool {
        guard let predictor = cache[tag] else {
            return false
        }
        cache.removeValue(forKey: tag)
        predictor.dispose()
        return true
    }

    private func createRawPrediction (
        tag: String,
        clientId: String? = nil,
        configurationId: String? = nil,
        predictionId: String? = nil
    ) async throws -> Prediction {
        return try await client.request(
            method: "POST",
            path: "/predictions",
            payload: [
                "tag": tag,
                "clientId": clientId ?? Configuration.clientId,
                "configurationId": configurationId ?? Configuration.uniqueId,
                "predictionId": predictionId
            ]
        )!
    }
    
    private func getPredictor (
        tag: String,
        acceleration: Acceleration = .auto,
        device: MTLDevice? = nil,
        clientId: String? = nil,
        configurationId: String? = nil
    ) async throws -> CPredictor {
        if let predictor = cache[tag] {
            return predictor
        }
        let prediction = try await createRawPrediction(
            tag: tag,
            clientId: clientId,
            configurationId: configurationId,
            predictionId: PredictionService.predictionCache[tag]?.id
        )
        let configuration = Configuration()
        defer {
            configuration.dispose()
        }
        configuration.tag = prediction.tag
        configuration.token = prediction.configuration
        configuration.acceleration = acceleration
        configuration.device = device
        for resource in prediction.resources! {
            if resource.type != "dso" {
                let path = try getResourcePath(resource: resource)
                try configuration.addResource(type: resource.type, path: path)
            }
        }
        let predictor = CPredictor(configuration: configuration)
        cache[tag] = predictor
        return predictor
    }

    private func getResourcePath (resource: PredictionResource) throws -> String { // INCOMPLETE
        return ""
    }

    private func getResourceName (url: String) -> String {
        guard let uri = URL(string: url) else { return "" }
        return uri.lastPathComponent
    }

    private func toValue (input: Any?) -> Value { // INCOMPLETE
        
    }
    
    private func toValueMap (inputs: [String: Any?]) -> ValueMap {
        let map = ValueMap()
        for (key, value) in inputs {
            map[key] = toValue(input: value)
        }
        return map
    }
    
    private func toPrediction (tag: String, prediction: CPrediction) -> Prediction {
        
    }
    
    private struct ResolvedConfiguration : Codable {
        public let predictions: [Prediction]
    }
}
