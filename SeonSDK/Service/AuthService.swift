//
//  AuthService.swift
//  SeonSDK
//
//  Created by Amit on 15.09.24.
//

import Combine
import LocalAuthentication

public class AuthService: AuthServiceProvider {
    
    public init() {}
    
    public func authenticate() -> AnyPublisher<Bool, AuthServiceError> {
        let context = LAContext()
        var error: NSError?

        // Check if biometric authentication is available
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            return Future<Bool, AuthServiceError> { promise in
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Access to photos") { success, authenticationError in
                    DispatchQueue.main.async {
                        if success {
                            promise(.success(true))
                        } else if let error = authenticationError {
                            promise(.failure(.authenticationFailed(error)))
                        } else {
                            promise(.failure(.unknownError))
                        }
                    }
                }
            }
            .eraseToAnyPublisher()
        } else {
            // Biometric authentication is not available
            return Fail(error: AuthServiceError.biometricUnavailable)
                .eraseToAnyPublisher()
        }
    }
}
