//
//  PhotoStorageService.swift
//  SeonSDK
//
//  Created by Amit on 15.09.24.
//

import UIKit.UIImage
import Combine

public class PhotoStorageService: PhotoStorageProvider {
    private let folderName = "SavedPhotos"
    
    private var folderURL: URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(folderName)
    }
    
    public init() {
        createFolderIfNeeded()
    }
    
    // Create a folder for saving photos, if it doesn't exist
    private func createFolderIfNeeded() {
        guard let folderURL = folderURL else { return }
        if !FileManager.default.fileExists(atPath: folderURL.path) {
            do {
                try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Error creating folder: \(error.localizedDescription)")
            }
        }
    }
    
    // Save a photo to the folder and return a publisher
    public func savePhoto(_ image: UIImage) -> AnyPublisher<Void, PhotoStorageError> {
        return Future<Void, PhotoStorageError> { promise in
            guard let folderURL = self.folderURL else {
                promise(.failure(.folderCreationFailed))
                return
            }
            
            let imageData = image.jpegData(compressionQuality: 0.8)
            let fileName = UUID().uuidString + ".jpg"
            let fileURL = folderURL.appendingPathComponent(fileName)
            
            do {
                try imageData?.write(to: fileURL)
                promise(.success(()))
            } catch {
                print("Error saving photo: \(error.localizedDescription)")
                promise(.failure(.saveFailed))
            }
        }
        .eraseToAnyPublisher()
    }
    
    // Load all photos from the folder and return a publisher
    public func fetchPhotos() -> AnyPublisher<[UIImage], PhotoStorageError> {
        return Future<[UIImage], PhotoStorageError> { promise in
            guard let folderURL = self.folderURL else {
                promise(.failure(.loadFailed))
                return
            }
            
            var images: [UIImage] = []
            
            do {
                let fileURLs = try FileManager.default.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil)
                for url in fileURLs {
                    if let imageData = try? Data(contentsOf: url), let image = UIImage(data: imageData) {
                        images.append(image)
                    } else {
                        promise(.failure(.dataConversionFailed))
                        return
                    }
                }
                
                promise(.success(images))
            } catch {
                print("Error loading photos: \(error.localizedDescription)")
                promise(.failure(.loadFailed))
            }
        }
        .eraseToAnyPublisher()
    }
    
    // Delete a photo and return a publisher
    public func deletePhoto(at index: Int) -> AnyPublisher<Void, PhotoStorageError> {
        return Future<Void, PhotoStorageError> { promise in
            guard let folderURL = self.folderURL else {
                promise(.failure(.deleteFailed))
                return
            }
            
            do {
                let fileURLs = try FileManager.default.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil)
                if index < fileURLs.count {
                    try FileManager.default.removeItem(at: fileURLs[index])
                    promise(.success(()))
                } else {
                    promise(.failure(.deleteFailed))
                }
            } catch {
                print("Error deleting photo: \(error.localizedDescription)")
                promise(.failure(.deleteFailed))
            }
        }
        .eraseToAnyPublisher()
    }
}
