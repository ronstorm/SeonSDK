//
//  AuthServiceProvider.swift
//  SeonSDK
//
//  Created by Amit on 15.09.24.
//

import Foundation

public protocol AuthServiceProvider {
    func authenticate() async throws -> Bool
}
