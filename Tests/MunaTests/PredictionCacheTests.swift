/*
*   Muna
*   Copyright © 2026 NatML Inc. All rights reserved.
*/

import Foundation
import XCTest
@testable import Muna

final class PredictionCacheTests: XCTestCase {

    func testCacheKeyIncludesAllIdentityFields() {
        let base = PredictionCacheKey(tag: "tag", target: "target", configurationId: "configuration")

        XCTAssertNotEqual(
            base.storageKey,
            PredictionCacheKey(tag: "other", target: "target", configurationId: "configuration").storageKey
        )
        XCTAssertNotEqual(
            base.storageKey,
            PredictionCacheKey(tag: "tag", target: "other", configurationId: "configuration").storageKey
        )
        XCTAssertNotEqual(
            base.storageKey,
            PredictionCacheKey(tag: "tag", target: "target", configurationId: "other").storageKey
        )
    }

    func testPredictionCachePersistsPrediction() throws {
        let suiteName = "PredictionCacheTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let store = PredictionCacheStore(defaults: defaults)
        let key = PredictionCacheKey(tag: "tag", target: "target", configurationId: "configuration")
        let prediction = createPrediction(token: createToken(iat: 100, exp: 1_100))

        store.set(prediction, for: key)
        let cached = try XCTUnwrap(store.prediction(for: key))

        XCTAssertEqual(cached.id, prediction.id)
        XCTAssertEqual(cached.configuration, prediction.configuration)
        XCTAssertEqual(cached.resources?.first?.url, prediction.resources?.first?.url)
    }

    func testFirstLoadFetchesAndPersists() async throws {
        let suiteName = "PredictionCacheTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let store = PredictionCacheStore(defaults: defaults)
        let key = PredictionCacheKey(tag: "tag", target: "target", configurationId: "configuration")
        var fetchCount = 0

        let result = try await store.getOrRefreshPrediction(for: key) {
            fetchCount += 1
            return self.createPrediction(token: self.createToken(iat: 100, exp: 1_100))
        }

        XCTAssertEqual(fetchCount, 1)
        XCTAssertFalse(result.usedCache)
        XCTAssertNotNil(store.prediction(for: key))
    }

    func testRefreshFailureUsesExpiredPrediction() async throws {
        let suiteName = "PredictionCacheTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let store = PredictionCacheStore(defaults: defaults)
        let key = PredictionCacheKey(tag: "tag", target: "target", configurationId: "configuration")
        let cached = createPrediction(token: createToken(iat: 100, exp: 1_100))
        store.set(cached, for: key)

        let result = try await store.getOrRefreshPrediction(
            for: key,
            now: Date(timeIntervalSince1970: 1_200)
        ) {
            throw URLError(.notConnectedToInternet)
        }

        XCTAssertTrue(result.usedCache)
        XCTAssertEqual(result.prediction.configuration, cached.configuration)
    }

    func testRefreshesAtHalfLife() {
        let token = createToken(iat: 100, exp: 1_100)

        XCTAssertFalse(ConfigurationTokenRefreshPolicy.shouldRefresh(
            token: token,
            now: Date(timeIntervalSince1970: 599)
        ))
        XCTAssertTrue(ConfigurationTokenRefreshPolicy.shouldRefresh(
            token: token,
            now: Date(timeIntervalSince1970: 600)
        ))
    }

    func testExpiredAndMalformedTokensRefresh() {
        XCTAssertTrue(ConfigurationTokenRefreshPolicy.shouldRefresh(
            token: createToken(iat: 100, exp: 1_100),
            now: Date(timeIntervalSince1970: 1_200)
        ))
        XCTAssertTrue(ConfigurationTokenRefreshPolicy.shouldRefresh(
            token: "not-a-token",
            now: Date(timeIntervalSince1970: 1_200)
        ))
    }

    func testLegacyTokenDoesNotRefresh() {
        XCTAssertFalse(ConfigurationTokenRefreshPolicy.shouldRefresh(
            token: createToken(iat: 100),
            now: Date(timeIntervalSince1970: 10_000)
        ))
    }

    private func createToken(iat: Int, exp: Int? = nil) -> String {
        let header = encode(["alg": "EdDSA", "typ": "JWT"])
        var claims = ["iat": iat]
        claims["exp"] = exp
        return "\(header).\(encode(claims)).signature"
    }

    private func createPrediction(token: String) -> Prediction {
        Prediction(
            id: "prediction",
            tag: "tag",
            created: Date(timeIntervalSince1970: 100),
            results: nil,
            latency: nil,
            error: nil,
            logs: nil,
            configuration: token,
            resources: [
                PredictionResource(type: "dso", url: "https://example.com/model", name: nil)
            ]
        )
    }

    private func encode(_ object: Any) -> String {
        let data = try! JSONSerialization.data(withJSONObject: object)
        return data.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
