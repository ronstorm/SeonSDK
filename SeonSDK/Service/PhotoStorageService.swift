//
//  PhotoStorageService.swift
//  SeonSDK
//
//  Created by Amit on 15.09.24.
//

import UIKit.UIImage
import Combine

/// `PhotoStorageService` is a concrete implementation of the `PhotoStorageProvider` protocol.
/// It handles saving, loading, and deleting photos in the device's file system, specifically within a designated folder.
public class PhotoStorageService: PhotoStorageProvider {
    
    /// The name of the folder where photos will be stored.
    private let folderName = "SavedPhotos"
    
    /// Computed property to get the URL of the folder where photos will be stored.
    private var folderURL: URL? {
        // Retrieves the URL for the document directory and appends the folder name to it.
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(folderName)
    }
    
    /// Initializes the `PhotoStorageService` and creates the folder for saving photos if it doesn't exist.
    public init() {
        createFolderIfNeeded()
    }
    
    /// Creates a folder for saving photos if it does not already exist.
    private func createFolderIfNeeded() {
        guard let folderURL = folderURL else { return }
        if !FileManager.default.fileExists(atPath: folderURL.path) {
            do {
                // Attempts to create the directory with intermediate directories if necessary.
                try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
            } catch {
                // Logs an error message if folder creation fails.
                print("Error creating folder: \(error.localizedDescription)")
            }
        }
    }
    
    /// Saves a photo to the designated folder and returns a publisher that signals the completion of the operation.
    /// - Parameter image: The `UIImage` to be saved.
    /// - Returns: A publisher that emits `Void` on success or a `PhotoStorageError` on failure.
    public func savePhoto(_ image: UIImage) -> AnyPublisher<Void, PhotoStorageError> {
        return Future<Void, PhotoStorageError> { promise in
            guard let folderURL = self.folderURL else {
                // Fails if the folder URL could not be determined.
                promise(.failure(.folderCreationFailed))
                return
            }
            
            // Converts the UIImage to JPEG data with a specified compression quality.
            let imageData = image.jpegData(compressionQuality: 0.8)
            // Generates a unique filename for the photo.
            let fileName = UUID().uuidString + ".jpg"
            let fileURL = folderURL.appendingPathComponent(fileName)
            
            do {
                // Attempts to write the image data to the file URL.
                try imageData?.write(to: fileURL)
                promise(.success(())) // Signals success if the photo is saved successfully.
            } catch {
                // Logs the error and signals failure if the save operation fails.
                print("Error saving photo: \(error.localizedDescription)")
                promise(.failure(.saveFailed))
            }
        }
        .eraseToAnyPublisher() // Converts the Future into an AnyPublisher.
    }
    
    /// Loads all photos from the designated folder and returns a publisher with the result.
    /// - Returns: A publisher that emits an array of `UIImage` objects on success or a `PhotoStorageError` on failure.
    public func fetchPhotos() -> AnyPublisher<[UIImage], PhotoStorageError> {
        return Future<[UIImage], PhotoStorageError> { promise in
            guard let folderURL = self.folderURL else {
                // Fails if the folder URL could not be determined.
                promise(.failure(.loadFailed))
                return
            }
            
            var images: [UIImage] = []
            
            do {
                // Retrieves all file URLs from the folder.
                let fileURLs = try FileManager.default.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil)
                // Iterates over each file URL to load the image data.
                for url in fileURLs {
                    if let imageData = try? Data(contentsOf: url), let image = UIImage(data: imageData) {
                        images.append(image) // Adds the successfully loaded image to the list.
                    } else {
                        // Signals failure if the image data could not be converted to a UIImage.
                        promise(.failure(.dataConversionFailed))
                        return
                    }
                }
                
                promise(.success(images)) // Signals success with the loaded images.
            } catch {
                // Logs the error and signals failure if the load operation fails.
                print("Error loading photos: \(error.localizedDescription)")
                promise(.failure(.loadFailed))
            }
        }
        .eraseToAnyPublisher() // Converts the Future into an AnyPublisher.
    }
    
    /// Deletes a photo at the specified index in the folder and returns a publisher with the result.
    /// - Parameter index: The index of the photo to delete.
    /// - Returns: A publisher that emits `Void` on success or a `PhotoStorageError` on failure.
    public func deletePhoto(at index: Int) -> AnyPublisher<Void, PhotoStorageError> {
        return Future<Void, PhotoStorageError> { promise in
            guard let folderURL = self.folderURL else {
                // Fails if the folder URL could not be determined.
                promise(.failure(.deleteFailed))
                return
            }
            
            do {
                // Retrieves all file URLs from the folder.
                let fileURLs = try FileManager.default.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil)
                if index < fileURLs.count {
                    // Attempts to remove the file at the specified index.
                    try FileManager.default.removeItem(at: fileURLs[index])
                    promise(.success(())) // Signals success if the file is deleted successfully.
                } else {
                    // Signals failure if the specified index is out of bounds.
                    promise(.failure(.deleteFailed))
                }
            } catch {
                // Logs the error and signals failure if the delete operation fails.
                print("Error deleting photo: \(error.localizedDescription)")
                promise(.failure(.deleteFailed))
            }
        }
        .eraseToAnyPublisher() // Converts the Future into an AnyPublisher.
    }
}
