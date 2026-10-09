//
//  UserTests.swift
//  Function
//
//  Created by Yusuf Olokoba on 9/21/2024.
//  Copyright © 2026 NatML Inc. All rights reserved.
//

import XCTest
@testable import Muna

final class UserTests: XCTestCase {
    
    func testRetrieveUser () async throws {
        let fxn = Muna()
        let user = try await fxn.users.retrieve()
        XCTAssertNotNil(user)
    }
    
    func testRetrieveNilUser () async throws {
        let fxn = Muna()
        let user = try await fxn.users.retrieve()
        XCTAssertNil(user)
    }
}
