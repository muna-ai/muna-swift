//
//  PredictionTests.swift
//  Function
//
//  Created by Yusuf Olokoba on 9/21/2024.
//  Copyright © 2025 NatML Inc. All rights reserved.
//

import XCTest
@testable import Muna

final class PredictionTests : XCTestCase {

    func testConfigurationIds () async throws {
        let uniqueId = Configuration.uniqueId;
        let clientId = Configuration.clientId;
        XCTAssertNotNil(uniqueId)
        XCTAssertNotNil(clientId)
    }
}
