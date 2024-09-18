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
    func deletePhoto(at index: Int) -> AnyPublisher<Void, PhotoStorageError>
}

public enum PhotoStorageError: Error, LocalizedError {
    case folderCreationFailed
    case saveFailed
    case loadFailed
    case deleteFailed
    case dataConversionFailed

    public var errorDescription: String? {
        switch self {
        case .folderCreationFailed:
            return "Failed to create the folder for saving photos."
        case .saveFailed:
            return "Failed to save the photo."
        case .loadFailed:
            return "Failed to load the photos."
        case .deleteFailed:
            return "Failed to delete the photo."
        case .dataConversionFailed:
            return "Failed to convert data to image."
        }
    }
}
