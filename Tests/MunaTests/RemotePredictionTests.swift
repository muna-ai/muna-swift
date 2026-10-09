//
//  RemotePredictionTests.swift
//  Function
//
//  Created by Yusuf Olokoba on 1/25/2025.
//  Copyright © 2026 NatML Inc. All rights reserved.
//

import XCTest
@testable import Muna

final class RemotePredictionTests : XCTestCase {
    
    func testCreatePrediction () async throws {
        let tag = "@fxn/greeting"
        let fxn = Muna(accessKey: "")
        let prediction = try await fxn.beta.predictions.remote.create(
            tag: tag,
            inputs: ["name": "Yusuf"]
        )
        XCTAssertNotNil(prediction)
        XCTAssertTrue(prediction.tag == tag)
        XCTAssertTrue(prediction.results != nil && prediction.results?.count == 1)
        XCTAssertTrue(prediction.results?[0] is String)
    }
}
