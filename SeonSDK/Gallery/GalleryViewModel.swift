//
//  GalleryViewModel.swift
//  SeonSDK
//
//  Created by Amit on 17.09.24.
//

import Combine
import SwiftUI

/// `GalleryViewModel` manages the state and logic for displaying and manipulating photos in the gallery view.
/// It interacts with the `PhotoStorageProvider` to load and delete photos, and it handles errors that may occur
/// during these operations.
class GalleryViewModel: ObservableObject {
    
    /// Published array of photos displayed in the gallery, which updates the UI when changed.
    @Published var photos: [Photo] = []
    
    /// Published property to display error messages if an operation fails.
    @Published var errorMessage: String? = nil
    
    /// Controls error alert display
    @Published var showError: Bool = false
    
    /// Controls the selected photo for full-screen presentation
    @Published var selectedPhoto: Photo? = nil
    
    /// The service responsible for managing photo storage operations (save, load, delete).
    private let photoStorageService: PhotoStorageProvider
    
    /// A set to manage Combine subscriptions, ensuring proper memory management of async operations.
    private var cancellables = Set<AnyCancellable>()
    
    /// Initializes the `GalleryViewModel` with a storage service and loads the photos from the storage.
    /// - Parameter photoStorageService: A provider for photo storage operations, defaulting to `PhotoStorageService`.
    init(photoStorageService: PhotoStorageProvider = PhotoStorageService()) {
        self.photoStorageService = photoStorageService
        loadPhotos() // Loads the photos upon initialization.
    }
    
    /// Loads photos asynchronously from the storage service.
    /// It updates the `photos` array with the loaded images or sets an error message if the operation fails.
    func loadPhotos() {
        photoStorageService.fetchPhotos()
            .sink { completion in
                switch completion {
                case .failure(let error):
                    // Sets an error message if loading photos fails.
                    DispatchQueue.main.async {
                        self.errorMessage = error.localizedDescription
                        self.showError = true
                    }
                case .finished:
                    break
                }
            } receiveValue: { uiImages in
                // Maps the loaded `UIImage` objects into `Photo` models and updates the photos array.
                DispatchQueue.main.async {
                    self.photos = uiImages.map { Photo(image: $0) }
                }
            }
            .store(in: &cancellables) // Stores the subscription to manage its lifecycle.
    }
    
    /// Deletes a photo at the specified index asynchronously.
    /// It removes the photo from storage and updates the `photos` array if successful, or sets an error message on failure.
    /// - Parameter index: The index of the photo to delete.
    func deletePhoto(at index: Int) {
        photoStorageService.deletePhoto(at: index)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    // Sets an error message if deleting the photo fails.
                    DispatchQueue.main.async {
                        self.errorMessage = error.localizedDescription
                        self.showError = true
                    }
                case .finished:
                    break
                }
            } receiveValue: {
                // Removes the photo from the array if the deletion is successful.
                DispatchQueue.main.async {
                    self.photos.remove(at: index)
                }
            }
            .store(in: &cancellables) // Stores the subscription to manage its lifecycle.
    }
    
    /// Select a photo for full-screen viewing
    func selectPhoto(_ photo: Photo) {
        selectedPhoto = photo
    }
    
    /// Clear the selected photo
    func clearSelectedPhoto() {
        selectedPhoto = nil
    }
}
