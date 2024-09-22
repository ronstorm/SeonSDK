//
//  CameraViewModel.swift
//  SeonSDK
//
//  Created by Amit on 17.09.24.
//

import Combine
import UIKit.UIImage

/// `CameraViewModel` acts as the ViewModel in the MVVM architecture for the Camera View,
/// managing the state and interactions of the camera, including capturing photos, switching cameras,
/// toggling flash, and handling errors. It conforms to `ObservableObject` to allow SwiftUI views
/// to reactively update when the state changes.
public class CameraViewModel: ObservableObject {
    
    /// The captured image from the camera, bound to the view for display.
    @Published public var capturedImage: UIImage?
    
    /// Flag indicating whether an error should be shown in the UI.
    @Published public var showError: Bool = false
    
    /// The error message to display if something goes wrong.
    @Published public var errorMessage: String = ""
    
    /// Indicates if the camera session is currently active and ready for use.
    @Published public var isCameraReady: Bool = false
    
    /// A set to manage Combine subscriptions for asynchronous operations,
    /// ensuring proper memory management and cancellation when needed.
    private var cancellables = Set<AnyCancellable>()
    
    /// The camera service that provides the camera functionality, following the `CameraServiceProvider` protocol.
    public var cameraService: CameraServiceProvider
    
    /// Initializes the `CameraViewModel` with a default or injected camera service.
    /// - Parameter cameraService: A provider that implements camera functionalities, defaulting to `CameraService`.
    public init(cameraService: CameraServiceProvider = CameraService()) {
        self.cameraService = cameraService
    }
    
    /// A computed property that returns the appropriate icon name for the current flash mode.
    /// This property is used by the UI to display the correct flash state.
    public var flashIcon: String {
        switch cameraService.flashMode {
        case .auto:
            return "bolt.badge.a.fill" // Auto flash icon
        case .on:
            return "bolt.fill" // Flash on icon
        case .off:
            return "bolt.slash.fill" // Flash off icon
        @unknown default:
            return "bolt.slash.fill" // Default to off if an unknown mode is encountered
        }
    }
    
    /// Starts the camera session and sets the camera as ready.
    /// This method is called when the camera view appears and the session needs to be started.
    public func startCamera() {
        cameraService.startSession()
        isCameraReady = true
    }
    
    /// Stops the camera session and marks the camera as not ready.
    /// This method is called when the camera view disappears or the session needs to be stopped.
    public func stopCamera() {
        cameraService.stopSession()
        isCameraReady = false
    }
    
    /// Toggles the flash mode between `.auto`, `.on`, and `.off`.
    /// It sends an `objectWillChange` signal to ensure the UI updates to reflect the flash mode change.
    public func toggleFlash() {
        cameraService.toggleFlashMode()
        objectWillChange.send() // Notifies SwiftUI to update the flash icon.
    }
    
    /// Switches between the front and rear cameras.
    public func switchCamera() {
        cameraService.switchCamera()
    }
    
    /// Initiates the photo capture process and handles the result.
    /// It listens to the result of the capture operation and updates the UI accordingly,
    /// either showing the captured image or displaying an error.
    public func capturePhoto() {
        // Triggers the photo capture using the camera service and handles the Combine publisher.
        cameraService.capturePhoto()
            .sink { completion in
                // Handles the completion state of the capture operation.
                if case .failure(let error) = completion {
                    DispatchQueue.main.async {
                        // Updates the UI with the error message if capture fails.
                        self.errorMessage = error.localizedDescription
                        self.showError = true
                    }
                }
            } receiveValue: { image in
                // Updates the UI with the captured image when the operation succeeds.
                DispatchQueue.main.async {
                    self.capturedImage = image
                }
            }
            .store(in: &cancellables) // Stores the subscription to manage its lifecycle.
    }
}
