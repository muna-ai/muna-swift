//
//  PredictionTests.swift
//  Function
//
//  Created by Yusuf Olokoba on 9/21/2024.
//  Copyright © 2024 NatML Inc. All rights reserved.
//

import XCTest
@testable import FunctionSwift

final class PredictionTests : XCTestCase {

    func testConfigurationIds () async throws {
        let uniqueId = FunctionSwift.Configuration.uniqueId;
        let clientId = FunctionSwift.Configuration.clientId;
        XCTAssertNotNil(uniqueId)
        XCTAssertNotNil(clientId)
    }
}
