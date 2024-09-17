//
//  PhotoSDK.swift
//  PhotoSDK
//
//  Created by Amit on 16.09.24.
//

import SwiftUI
import Combine

public class PhotoSDK {
    private let photoStorageService = PhotoStorageService()
    private let authService: AuthServiceProvider
    private var cancellables = Set<AnyCancellable>()

    public init(authService: AuthServiceProvider = AuthService()) {
        self.authService = authService
    }

    /// Method to take a photo and store it locally.
    /// This function returns a SwiftUI view for capturing photos.
    public func takePhoto(completion: @escaping (Result<UIImage, Error>) -> Void) -> some View {
        return CameraView(onCapture: { image in
            // Save photo locally
            self.photoStorageService.savePhoto(image) { success in
                if success {
                    completion(.success(image))
                } else {
                    completion(.failure(NSError(domain: "PhotoSDK", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to save photo."])))
                }
            }
        })
    }

    /// Method to authenticate the user via biometrics and return a GalleryView on success.
    public func accessPhotos(onAuthenticated: @escaping (Result<AnyView, Error>) -> Void) {
        authService.authenticate()
            .sink { completion in
                switch completion {
                case .failure(let error):
                    // Authentication failed, return the error
                    onAuthenticated(.failure(error))
                case .finished:
                    break
                }
            } receiveValue: { success in
                if success {
                    // Authentication succeeded, return the gallery view
                    let galleryView = AnyView(GalleryView())
                    onAuthenticated(.success(galleryView))
                } else {
                    // Unexpected failure
                    let error = NSError(domain: "PhotoSDK", code: -2, userInfo: [NSLocalizedDescriptionKey: "Authentication failed. Access denied."])
                    onAuthenticated(.failure(error))
                }
            }
            .store(in: &cancellables)
    }
}
