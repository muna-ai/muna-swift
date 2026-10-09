/*
*   Muna
*   Copyright © 2026 NatML Inc. All rights reserved.
*/

import Foundation

internal struct PredictionCacheKey: Hashable {

    let tag: String
    let target: String
    let configurationId: String

    var storageKey: String {
        let parts = [tag, target, configurationId].map { value in
            Data(value.utf8)
                .base64EncodedString()
                .replacingOccurrences(of: "+", with: "-")
                .replacingOccurrences(of: "/", with: "_")
                .replacingOccurrences(of: "=", with: "")
        }
        return "ai.muna.prediction-cache.v1.\(parts.joined(separator: "."))"
    }
}

internal struct PredictionCacheStore {

    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func prediction(for key: PredictionCacheKey) -> Prediction? {
        guard let data = defaults.data(forKey: key.storageKey) else {
            return nil
        }
        return try? decoder.decode(Prediction.self, from: data)
    }

    func set(_ prediction: Prediction, for key: PredictionCacheKey) {
        guard let data = try? encoder.encode(prediction) else {
            return
        }
        defaults.set(data, forKey: key.storageKey)
    }

    func removePrediction(for key: PredictionCacheKey) {
        defaults.removeObject(forKey: key.storageKey)
    }

    func getOrRefreshPrediction(
        for key: PredictionCacheKey,
        now: Date = Date(),
        fetch: () async throws -> Prediction
    ) async throws -> (prediction: Prediction, usedCache: Bool) {
        if let cached = prediction(for: key) {
            let shouldRefresh = cached.configuration.map {
                ConfigurationTokenRefreshPolicy.shouldRefresh(token: $0, now: now)
            } ?? true
            if !shouldRefresh {
                return (cached, true)
            }
            do {
                let fresh = try await fetch()
                set(fresh, for: key)
                return (fresh, false)
            } catch {
                // Expiration is only a refresh hint. Preserve offline startup by
                // falling back even when the cached token is past exp.
                return (cached, true)
            }
        }
        // A device without a cached token must contact the API at least once.
        let fresh = try await fetch()
        set(fresh, for: key)
        return (fresh, false)
    }
}

internal enum ConfigurationTokenRefreshPolicy {

    static func shouldRefresh(
        token: String,
        now: Date = Date()
    ) -> Bool {
        guard let claims = claims(from: token) else {
            return true
        }
        guard let expiration = number(claims["exp"]) else {
            return false // Legacy configuration tokens do not expire.
        }
        guard let issuedAt = number(claims["iat"]), expiration > issuedAt else {
            return now.timeIntervalSince1970 >= expiration
        }
        let lifetime = expiration - issuedAt
        let refreshAt = issuedAt + lifetime * 0.5
        return now.timeIntervalSince1970 >= refreshAt
    }

    private static func claims(from token: String) -> [String: Any]? {
        let parts = token.split(separator: ".", omittingEmptySubsequences: false)
        guard parts.count >= 2 else {
            return nil
        }
        var payload = String(parts[1])
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        payload += String(repeating: "=", count: (4 - payload.count % 4) % 4)
        guard
            let data = Data(base64Encoded: payload),
            let object = try? JSONSerialization.jsonObject(with: data),
            let claims = object as? [String: Any]
        else {
            return nil
        }
        return claims
    }

    private static func number(_ value: Any?) -> Double? {
        switch value {
        case let value as NSNumber:
            return value.doubleValue
        case let value as Double:
            return value
        case let value as Int:
            return Double(value)
        default:
            return nil
        }
    }

}
