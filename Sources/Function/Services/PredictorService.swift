//
//  Predictor.swift
//  Function
//
//  Created by Yusuf Olokoba on 9/21/2024.
//  Copyright © 2024 NatML Inc. All rights reserved.
//

public class PredictorService {
    
    private let client: FunctionClient
        
    internal init (client: FunctionClient) {
        self.client = client
    }
    
    public func retrieve (tag: String) async throws -> Predictor? {
        do {
            return try await client.request(method: "GET", path: "/predictors/\(tag)") as Predictor?
        } catch let error as FunctionAPIError {
            switch error {
                case .requestFailed(_, let status) where status == 404: return nil
                default: throw error
            }
        }
    }
}
