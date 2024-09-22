//
//  AuthService.swift
//  SeonSDK
//
//  Created by Amit on 15.09.24.
//

import Combine
import LocalAuthentication

/// `AuthService` is a concrete implementation of the `AuthServiceProvider` protocol that provides
/// biometric authentication (Face ID, Touch ID) using the LocalAuthentication framework.
/// It manages the asynchronous authentication process and handles errors gracefully.
public class AuthService: AuthServiceProvider {
    
    /// Initializes a new instance of `AuthService`.
    public init() {}

    /// Authenticates the user using the device's biometric capabilities (e.g., Face ID, Touch ID).
    /// - Returns: A Combine publisher that emits `true` if authentication is successful, or an `AuthServiceError`
    /// if the authentication fails or is unavailable.
    public func authenticate() -> AnyPublisher<Bool, AuthServiceError> {
        // Creates a context for managing the authentication session.
        let context = LAContext()
        var error: NSError?

        // Checks if the device supports biometric authentication and if it can be evaluated.
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            // Uses a `Future` to handle the asynchronous biometric evaluation.
            return Future<Bool, AuthServiceError> { promise in
                // Initiates the biometric authentication with a localized reason message.
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Access to photos") { success, authenticationError in
                    DispatchQueue.main.async {
                        if success {
                            // If authentication is successful, complete the publisher with a success.
                            promise(.success(true))
                        } else if let error = authenticationError {
                            // If there is an authentication error, complete with a failure.
                            promise(.failure(.authenticationFailed(error)))
                        } else {
                            // Handles unexpected cases where no specific error is provided.
                            promise(.failure(.unexpectedError))
                        }
                    }
                }
            }
            .eraseToAnyPublisher() // Converts the `Future` into a generic `AnyPublisher`.
        } else {
            // If biometric authentication is not available, return an appropriate error.
            return Fail(error: AuthServiceError.biometricUnavailable)
                .eraseToAnyPublisher()
        }
    }
}
