//
//  GalleryViewModel.swift
//  SeonSDK
//
//  Created by Amit on 17.09.24.
//

import UIKit.UIImage

class GalleryViewModel: ObservableObject {
    @Published var photos: [UIImage] = []
    private let photoStorageService = PhotoStorageService()

    init() {
        loadPhotos()
    }

    func loadPhotos() {
        self.photos = photoStorageService.loadPhotos()
    }
    
    func deletePhoto(at index: Int) {
        photoStorageService.deletePhoto(at: index) { [weak self] success in
            if success {
                DispatchQueue.main.async {
                    self?.photos.remove(at: index)
                }
            }
        }
    }
}
