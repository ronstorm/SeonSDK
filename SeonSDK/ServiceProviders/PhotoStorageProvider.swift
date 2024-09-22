//
//  PhotoStorageProvider.swift
//  SeonSDK
//
//  Created by Amit on 15.09.24.
//

import UIKit.UIImage
import Combine

/// `PhotoStorageProvider` is a protocol that defines the required functionalities for managing photo storage.
/// It abstracts the storage operations, allowing photos to be saved, fetched, and deleted asynchronously using Combine.
public protocol PhotoStorageProvider {
    
    /// Saves a given photo to persistent storage.
    func savePhoto(_ photo: UIImage) -> AnyPublisher<Void, PhotoStorageError>
    
    /// Fetches all saved photos from persistent storage.
    func fetchPhotos() -> AnyPublisher<[UIImage], PhotoStorageError>
    
    /// Deletes a photo at the specified index from persistent storage.
    func deletePhoto(at index: Int) -> AnyPublisher<Void, PhotoStorageError>
}

/// `PhotoStorageError` defines the possible errors that can occur during photo storage operations.
/// These errors provide descriptive messages for failures that occur while saving, fetching, or deleting photos.
public enum PhotoStorageError: Error, LocalizedError {
    
    /// Error indicating that the folder required for saving photos could not be created.
    case folderCreationFailed
    
    /// Error indicating that the save operation failed.
    case saveFailed
    
    /// Error indicating that the operation to load photos from storage failed.
    case loadFailed
    
    /// Error indicating that the operation to delete a photo failed.
    case deleteFailed
    
    /// Error indicating that there was a failure in converting data to an image format.
    case dataConversionFailed

    /// Provides user-friendly descriptions for each error case, which can be displayed in the UI or used for debugging.
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
