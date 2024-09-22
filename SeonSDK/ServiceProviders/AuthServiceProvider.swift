//
//  AuthServiceProvider.swift
//  SeonSDK
//
//  Created by Amit on 15.09.24.
//

import Combine
import LocalAuthentication

/// `AuthServiceProvider` is a protocol that defines the required functionality for user authentication.
/// It uses Combine to manage the asynchronous authentication process, allowing other components to subscribe
/// to the authentication result.
public protocol AuthServiceProvider {
    
    /// Initiates the authentication process, typically using biometrics (e.g., Face ID, Touch ID).
    func authenticate() -> AnyPublisher<Bool, AuthServiceError>
}

/// `AuthServiceError` defines the possible errors that can occur during the authentication process.
/// These errors provide detailed messages about specific issues such as unavailability of biometric hardware
/// or failures during the authentication attempt.
public enum AuthServiceError: Error, LocalizedError {
    
    /// Error indicating that biometric authentication (e.g., Face ID, Touch ID) is not available on the device.
    case biometricUnavailable
    
    /// Error that wraps any underlying errors that occur during the authentication process.
    /// - Parameter Error: The specific error encountered during the authentication attempt.
    case authenticationFailed(Error)
    
    /// A general catch-all error for any unexpected issues that do not fit into other cases.
    case unexpectedError

    /// Provides user-friendly error descriptions for each `AuthServiceError` case, which can be displayed
    /// in the UI or used in logging for easier debugging and user feedback.
    public var errorDescription: String? {
        switch self {
        case .biometricUnavailable:
            return "Biometric authentication is not available on this device."
        case .authenticationFailed(let error):
            return "Authentication failed: \(error.localizedDescription)"
        case .unexpectedError:
            return "Authentication failed. Access denied."
        }
    }
}
