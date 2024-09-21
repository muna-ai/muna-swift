//
//  Client.swift
//  Function
//
//  Created by Yusuf Olokoba on 9/21/2024.
//  Copyright © 2024 NatML Inc. All rights reserved.
//

import Foundation

public class FunctionClient {

    private let url: String
    private let auth: String
    
    public static let defaultURL = "https://api.fxn.ai/v1"

    init (accessKey: String? = nil, url: String? = nil) {
        self.url = url ?? FunctionClient.defaultURL;
        self.auth = accessKey != nil ? "Bearer \(accessKey!)" : ""
    }

    func request<T: Decodable> (
        method: String,
        path: String,
        payload: [String: Any?]? = nil,
        headers: [String: String]? = nil
    ) async throws -> T? {
        let url = URL(string: "\(self.url)\(path)")
        var request = URLRequest(url: url!)
        request.httpMethod = method
        // Add headers
        request.addValue(self.auth, forHTTPHeaderField: "Authorization")
        if let headers = headers {
            for (key, value) in headers {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        // Add payload
        if let payload = payload {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        // Request
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw FunctionAPIError.requestFailed(message: "Failed to request Function API", status: 500)
        }
        // Check error
        if httpResponse.statusCode >= 400 {
            let error = try? JSONDecoder().decode(ErrorResponse.self, from: data)
            guard let message = error?.errors.first?.message else {
                throw FunctionAPIError.requestFailed(message: "An unknown error occurred", status: httpResponse.statusCode)
            }
            throw FunctionAPIError.requestFailed(message: message, status: httpResponse.statusCode)
        }
        // Decode the response data
        return try JSONDecoder().decode(T.self, from: data)
    }
}

public enum FunctionAPIError: Error {
    
    case requestFailed (message: String, status: Int)
    
    var localizedDescription: String {
        switch self {
            case .requestFailed(let message, _): return message
        }
    }
}

struct ErrorResponse: Decodable {
    let errors: [ErrorDetail]

    struct ErrorDetail: Decodable {
        let message: String
    }
}
