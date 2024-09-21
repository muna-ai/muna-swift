import XCTest
@testable import Function

final class UserTests: XCTestCase {
    
    func testRetrieveUser () async throws {
        let fxn = Function()
        let user = try await fxn.users.retrieve()
        XCTAssertNotNil(user)
    }
    
    func testRetrieveNoUser () async throws {
        let fxn = Function()
        let user = try await fxn.users.retrieve()
        XCTAssertNil(user)
    }
}
