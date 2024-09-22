//
//  PredictorTests.swift
//  Function
//
//  Created by Yusuf Olokoba on 9/21/24.
//  Copyright © 2024 NatML Inc. All rights reserved.
//

import XCTest
@testable import Function

final class PredictorTests : XCTestCase {
    
    func testRetrievePredictor () async throws {
        let tag = "@fxn/greeting"
        let fxn = Function()
        let predictor = try await fxn.predictors.retrieve(tag: tag)
        XCTAssertNotNil(predictor)
        XCTAssertTrue(predictor?.tag == tag)
    }
    
    func testRetrieveNilPredictor () async throws {
        let fxn = Function()
        let predictor = try await fxn.predictors.retrieve(tag: "@fxn/404")
        XCTAssertNil(predictor)
    }
}
