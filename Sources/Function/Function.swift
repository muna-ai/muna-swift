//
//  Function.swift
//  Function
//
//  Created by Yusuf Olokoba on 10/21/2023.
//  Copyright © 2024 NatML Inc. All rights reserved.
//

import Function

/// Function client.
public class Function {

    /// Function project configuration.
    public struct Configuration : Codable {

        public let tags: [String]

        public let envPath: String?

        public init (tags: [String], envPath: String? = nil) {
            self.tags = tags
            self.envPath = envPath
        }
    }

    /// Manage users.
    public let users: UserService

    /// Manage predictors.
    public let predictors: PredictorService

    /// Make predictions.
    public let predictions: PredictionService

    private let client: FunctionClient

    /// Create the Function client.
    /// - Parameters:
    ///   - accessKey: Function access key.
    ///   - url: Function API URL.
    public init (accessKey: String? = nil, url: String? = nil) {
        let client = FunctionClient(accessKey: accessKey, url: url)
        self.client = client
        self.users = UserService(client: client)
        self.predictors = PredictorService(client: client)
        self.predictions = PredictionService(client: client)
    }
}

enum FunctionError: Error {

    case invalidArgument (message: String? = nil)
    case invalidOperation (message: String? = nil)
    case notImplemented
    case requestFailed (message: String, status: Int)

    var localizedDescription: String {
        switch self {
        case .invalidOperation(let message):    return message ?? "Operation is invalid"
        case .invalidArgument(let message):     return message ?? "One or more arguments are invalid"
        case .notImplemented:                   return "Operation is not implemented"
        case .requestFailed(let message, _):    return message
        }
    }
    
    internal static func from (status: FXNStatus) -> FunctionError {
        switch status {
        case FXN_ERROR_INVALID_ARGUMENT:    return .invalidArgument()
        case FXN_ERROR_INVALID_OPERATION:   return .invalidOperation()
        case FXN_ERROR_NOT_IMPLEMENTED:     return .notImplemented
        default:                            return .invalidOperation()
        }
    }
}
