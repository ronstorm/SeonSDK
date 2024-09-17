//
//  AuthServiceProvider.swift
//  SeonSDK
//
//  Created by Amit on 15.09.24.
//

import Combine

public protocol AuthServiceProvider {
    func authenticate() -> AnyPublisher<Bool, AuthServiceError>
}

public enum AuthServiceError: Error, LocalizedError {
    
}
