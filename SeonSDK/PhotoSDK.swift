//
//  PhotoSDK.swift
//  PhotoSDK
//
//  Created by Amit on 16.09.24.
//

import SwiftUI
import Combine

/// `PhotoSDK` is the main facade class for the PhotoSDK framework.
/// It provides a simple interface to the outside world with methods to take photos,
/// access previously taken photos, and authenticate the user using biometrics.
public class PhotoSDK {
    
    /// Service responsible for handling photo storage operations such as saving and retrieving photos.
    private let photoStorageService: PhotoStorageProvider
    
    /// Service responsible for handling user authentication, particularly biometric authentication.
    private let authService: AuthServiceProvider
    
    ///
    private var cancellables = Set<AnyCancellable>()
    
    /// Initializes the `PhotoSDK` with the required services for authentication and photo storage.
    /// - Parameters:
    ///   - authService: A provider for authentication, defaulting to `AuthService`.
    ///   - photoStorageService: A provider for photo storage, defaulting to `PhotoStorageService`.
    public init(authService: AuthServiceProvider = AuthService(),
                photoStorageService: PhotoStorageProvider = PhotoStorageService()) {
        self.authService = authService
        self.photoStorageService = photoStorageService
    }
    
    /// Provides a SwiftUI view for taking a photo using the device's camera.
    /// Captures the photo and stores it locally using the `PhotoStorageService`.
    /// - Parameter completion: A closure called upon photo capture with either the captured image or an error.
    /// - Returns: A SwiftUI `View` for capturing photos, typically utilizing the front-facing camera.
    public func takePhoto(completion: @escaping (Result<UIImage, Error>) -> Void) -> some View {
        return CameraView(onCapture: { image in
            // Save the captured photo using Combine-based photo storage
            self.photoStorageService.savePhoto(image)
                .sink { saveCompletion in
                    switch saveCompletion {
                    case .failure(let error):
                        // If saving fails, pass the error back to the caller.
                        completion(.failure(error))
                    case .finished:
                        break
                    }
                } receiveValue: {
                    // If saving succeeds, pass the captured image back to the caller.
                    completion(.success(image))
                }
                .store(in: &self.cancellables)
        })
    }
    
    /// Authenticates the user via biometrics and, on success, provides access to the gallery view.
    /// - Parameter onAuthenticated: A closure that returns either the gallery view or an error after authentication.
    public func accessPhotos(onAuthenticated: @escaping (Result<AnyView, Error>) -> Void) {
        
        // Initiates the biometric authentication process via the authentication service.
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
                    onAuthenticated(.failure(AuthServiceError.unexpectedError))
                }
            }
            .store(in: &cancellables)
    }
}
