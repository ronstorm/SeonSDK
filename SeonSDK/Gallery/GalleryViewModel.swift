//
//  GalleryViewModel.swift
//  SeonSDK
//
//  Created by Amit on 17.09.24.
//

import Combine
import SwiftUI

class GalleryViewModel: ObservableObject {
    @Published var photos: [Photo] = []
    @Published var errorMessage: String? = nil
    
    private let photoStorageService: PhotoStorageProvider
    private var cancellables = Set<AnyCancellable>()
    
    init(photoStorageService: PhotoStorageProvider = PhotoStorageService()) {
        self.photoStorageService = photoStorageService
        loadPhotos()
    }
    
    // Load photos asynchronously
    func loadPhotos() {
        photoStorageService.fetchPhotos()
            .sink { completion in
                switch completion {
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.errorMessage = error.localizedDescription
                    }
                case .finished:
                    break
                }
            } receiveValue: { uiImages in
                DispatchQueue.main.async {
                    self.photos = uiImages.map { Photo(image: $0) }
                }
            }
            .store(in: &cancellables)
    }
    
    // Delete photo asynchronously
    func deletePhoto(at index: Int) {
        photoStorageService.deletePhoto(at: index)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.errorMessage = error.localizedDescription
                    }
                case .finished:
                    break
                }
            } receiveValue: {
                DispatchQueue.main.async {
                    self.photos.remove(at: index)
                }
            }
            .store(in: &cancellables)
    }
}
