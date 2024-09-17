//
//  CameraServiceProvider.swift
//  SeonSDK
//
//  Created by Amit on 15.09.24.
//

import Foundation
import UIKit.UIImage

public protocol CameraServiceProvider {
    func capturePhoto() async throws -> UIImage
}
