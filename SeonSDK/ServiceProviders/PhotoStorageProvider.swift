//
//  PhotoStorageProvider.swift
//  SeonSDK
//
//  Created by Amit on 15.09.24.
//

import Foundation
import UIKit.UIImage

public protocol PhotoStorageProvider {
    func savePhoto(_ photo: UIImage) async throws
    func fetchPhotos() async throws -> [UIImage]
}
