//
//  AuthService.swift
//  SeonSDK
//
//  Created by Amit on 15.09.24.
//

import LocalAuthentication

class AuthService {
    func authenticateUser(completion: @escaping (Bool) -> Void) {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Access to photos") { success, authenticationError in
                DispatchQueue.main.async {
                    completion(success)
                }
            }
        } else {
            DispatchQueue.main.async {
                completion(false)   // Biometric not available
            }
        }
    }
}
