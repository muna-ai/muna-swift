//
//  RemotePredictionTests.swift
//  Function
//
//  Created by Yusuf Olokoba on 1/25/2025.
//  Copyright © 2025 NatML Inc. All rights reserved.
//

import XCTest
@testable import FunctionSwift

final class RemotePredictionTests : XCTestCase {
    
    func testCreatePrediction () async throws {
        let tag = "@fxn/greeting"
        let fxn = Function(accessKey: "fxn-PyJ4ZzZUqBxI7q8vlknJe")
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
