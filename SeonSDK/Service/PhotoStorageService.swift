//
//  PhotoStorageService.swift
//  SeonSDK
//
//  Created by Amit on 15.09.24.
//

import UIKit.UIImage

class PhotoStorageService {
    private let folderName = "SavedPhotos"
    private var folderURL: URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(folderName)
    }
    
    init() {
        createFolderIfNeeded()
    }
    
    // Create a folder for saving photos, if not exists
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
    
    // Save a photo to the folder
    func savePhoto(_ image: UIImage, completion: @escaping (Bool) -> Void) {
        guard let folderURL = folderURL else {
            completion(false)
            return
        }
        
        let imageData = image.jpegData(compressionQuality: 0.8)
        let fileName = UUID().uuidString + ".jpg"
        let fileURL = folderURL.appendingPathComponent(fileName)
        
        do {
            try imageData?.write(to: fileURL)
            completion(true)
        } catch {
            print("Error saving photo: \(error.localizedDescription)")
            completion(false)
        }
    }
    
    // Load all photos from the folder
    func loadPhotos() -> [UIImage] {
        guard let folderURL = folderURL else { return [] }
        var images: [UIImage] = []
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil)
            for url in fileURLs {
                if let imageData = try? Data(contentsOf: url), let image = UIImage(data: imageData) {
                    images.append(image)
                }
            }
        } catch {
            print("Error loading photos: \(error.localizedDescription)")
        }
        
        return images
    }
    
    // Delete a photo
    func deletePhoto(at index: Int, completion: @escaping (Bool) -> Void) {
        guard let folderURL = folderURL else {
            completion(false)
            return
        }
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil)
            if index < fileURLs.count {
                try FileManager.default.removeItem(at: fileURLs[index])
                completion(true)
            } else {
                completion(false)
            }
        } catch {
            print("Error deleting photo: \(error.localizedDescription)")
            completion(false)
        }
    }
}
