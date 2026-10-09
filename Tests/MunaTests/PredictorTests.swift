//
//  PredictorTests.swift
//  Function
//
//  Created by Yusuf Olokoba on 9/21/2024.
//  Copyright © 2025 NatML Inc. All rights reserved.
//

import XCTest
@testable import Muna

final class PredictorTests : XCTestCase {
    
    func testRetrievePredictor () async throws {
        let tag = "@fxn/greeting"
        let fxn = Muna()
        let predictor = try await fxn.predictors.retrieve(tag: tag)
        XCTAssertNotNil(predictor)
        XCTAssertTrue(predictor?.tag == tag)
    }
    
    func testRetrieveNilPredictor () async throws {
        let fxn = Muna()
        let predictor = try await fxn.predictors.retrieve(tag: "@fxn/404")
        XCTAssertNil(predictor)
    }
}
