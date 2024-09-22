//
//  CameraServiceProvider.swift
//  SeonSDK
//
//  Created by Amit on 15.09.24.
//

import UIKit.UIImage
import Combine
import AVFoundation

/// `CameraServiceProvider` is a protocol that defines the essential functionalities required
/// for interacting with the device's camera. This protocol abstracts camera operations
/// such as capturing photos, switching cameras, managing flash modes, and controlling
/// the camera session lifecycle.
public protocol CameraServiceProvider {
    
    /// Captures a photo using the active camera session.
    func capturePhoto() -> AnyPublisher<UIImage, CameraServiceError>
    
    /// Starts the camera session, initializing necessary components such as input devices
    /// and outputs. This is necessary before any photo capture can occur.
    func startSession()
    
    /// Stops the camera session, releasing resources associated with the camera.
    /// This is used to free up camera resources when they are no longer needed.
    func stopSession()
    
    /// Toggles the flash mode of the camera between auto, on, and off.
    /// This setting affects the flash behavior when capturing photos.
    func toggleFlashMode()
    
    /// Switches between the front and back cameras, allowing the user to select
    /// which camera to use for capturing photos.
    func switchCamera()
    
    /// Retrieves the preview layer associated with the active camera session.
    /// This layer can be used to display the camera feed within the app's UI.
    func getPreviewLayer() -> AVCaptureVideoPreviewLayer?
    
    /// The current flash mode of the camera, which controls how the flash behaves
    /// during photo capture. Modes include auto, on, and off.
    var flashMode: AVCaptureDevice.FlashMode { get }
}

/// `CameraServiceError` defines possible errors that can occur during camera operations.
/// These errors provide context about issues such as failed photo captures and
/// uninitialized components.
public enum CameraServiceError: Error, LocalizedError {
    
    /// Error indicating that the photo output is not properly initialized before capture.
    case photoOutputNotInitialized
    
    /// Error that wraps underlying errors from capture operations.
    /// - Parameter Error: The underlying error that occurred during capture.
    case captureFailed(Error)
    
    /// A catch-all for any unexpected errors that do not fit other cases.
    case unknown
    
    /// Provides user-friendly descriptions for each error case to facilitate debugging
    /// and enhance the user experience.
    public var errorDescription: String? {
        switch self {
        case .photoOutputNotInitialized:
            return "Photo output is not initialized."
        case .captureFailed(let error):
            return "Failed to capture photo: \(error.localizedDescription)"
        case .unknown:
            return "An unknown error occurred."
        }
    }
}
