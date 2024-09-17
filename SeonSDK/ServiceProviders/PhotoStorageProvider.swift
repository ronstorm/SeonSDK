//
//  PhotoStorageProvider.swift
//  SeonSDK
//
//  Created by Amit on 15.09.24.
//

import UIKit.UIImage
import Combine

public protocol PhotoStorageProvider {
    func savePhoto(_ photo: UIImage) -> AnyPublisher<Void, PhotoStorageError>
    func fetchPhotos() -> AnyPublisher<[UIImage], PhotoStorageError>
}

public enum PhotoStorageError: Error, LocalizedError {
    
}
