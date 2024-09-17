//
//  GalleryViewModel.swift
//  SeonSDK
//
//  Created by Amit on 17.09.24.
//

class GalleryViewModel: ObservableObject {
    
    @Published var photos: [Photo] = []
    private let photoStorageService = PhotoStorageService()

    init() {
        loadPhotos()
    }

    func loadPhotos() {
        let uiImages = photoStorageService.loadPhotos()
        self.photos = uiImages.map { Photo(image: $0) }  // Wrap UIImages in Photo
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
