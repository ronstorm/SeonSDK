//
//  AuthServiceProvider.swift
//  SeonSDK
//
//  Created by Amit on 15.09.24.
//

import Combine
import LocalAuthentication

public protocol AuthServiceProvider {
    func authenticate() -> AnyPublisher<Bool, AuthServiceError>
}

public enum AuthServiceError: Error, LocalizedError {
    case biometricUnavailable
    case authenticationFailed(Error)
    case unknownError

    public var errorDescription: String? {
        switch self {
        case .biometricUnavailable:
            return "Biometric authentication is not available on this device."
        case .authenticationFailed(let error):
            return "Authentication failed: \(error.localizedDescription)"
        case .unknownError:
            return "An unknown error occurred."
        }
    }
}
