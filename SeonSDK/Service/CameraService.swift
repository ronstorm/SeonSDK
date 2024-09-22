//
//  CameraService.swift
//  SeonSDK
//
//  Created by Amit on 15.09.24.
//

import AVFoundation
import UIKit.UIImage
import Combine

/// `CameraService` is responsible for managing the camera's lifecycle, capturing photos,
/// switching between cameras, toggling flash mode, and providing a preview layer for display.
/// It conforms to the `CameraServiceProvider` protocol, ensuring all required functionalities are implemented.
public class CameraService: NSObject, CameraServiceProvider {
    
    /// The session that coordinates the flow of data from the camera to outputs such as the preview layer and photo output.
    private var captureSession: AVCaptureSession?
    
    /// Represents the currently active camera (either front or rear).
    private var currentCamera: AVCaptureDevice?
    
    /// References to the front and rear cameras of the device.
    private var frontCamera: AVCaptureDevice?
    private var rearCamera: AVCaptureDevice?
    
    /// Handles the capture of still images from the camera.
    private var photoOutput: AVCapturePhotoOutput?
    
    /// Layer that displays the camera's live feed, typically added to a view for user interaction.
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    /// Completion handler to be called upon photo capture, used internally for direct feedback.
    private var completion: ((Result<UIImage, Error>) -> Void)?
    
    /// Current flash mode setting for photo capture (auto, on, off).
    public var flashMode: AVCaptureDevice.FlashMode = .auto
    
    /// A Combine subject that emits captured photos or errors during the capture process.
    private var photoCaptureSubject = PassthroughSubject<UIImage, CameraServiceError>()
    
    /// Initializes the `CameraService`, setting up the session and preparing the cameras for use.
    public override init() {
        super.init()
        setupSession()
    }
    
    /// Configures the camera session and initializes the preview layer.
    public func setupSession() {
        
        // Initializes the capture session.
        captureSession = AVCaptureSession()
        
        // Sets up references to the front and rear cameras.
        setupCameras()
        
        // Uses the front camera by default if available.
        if let camera = frontCamera {
            switchToCamera(camera)
        }
        
        // Initializes the photo output to capture still images.
        photoOutput = AVCapturePhotoOutput()
        if let photoOutput = photoOutput {
            captureSession?.addOutput(photoOutput)
        }
        
        // Sets up the preview layer for displaying the camera feed in the UI.
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        previewLayer?.videoGravity = .resizeAspectFill
    }
    
    /// Configures available front and rear cameras on the device.
    private func setupCameras() {
        
        // Accesses the default front and rear wide-angle cameras.
        frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
        rearCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
    }
    
    /// Toggles between the front and rear cameras during an active session.
    public func switchCamera() {
        guard let session = captureSession else { return }
        
        session.beginConfiguration()
        
        // Removes the existing input from the session.
        if let currentInput = session.inputs.first as? AVCaptureDeviceInput {
            session.removeInput(currentInput)
        }
        
        // Switches to the other camera based on the current camera's position.
        if let currentCamera = currentCamera, currentCamera.position == .back {
            if let frontCamera = frontCamera {
                switchToCamera(frontCamera)
            }
        } else {
            if let rearCamera = rearCamera {
                switchToCamera(rearCamera)
            }
        }
        
        session.commitConfiguration()
    }
    
    /// Helper method to switch the input to the specified camera.
    /// - Parameter camera: The camera device to switch to (front or rear).
    private func switchToCamera(_ camera: AVCaptureDevice) {
        do {
            // Creates a new input for the specified camera and adds it to the session.
            let input = try AVCaptureDeviceInput(device: camera)
            captureSession?.addInput(input)
            currentCamera = camera
        } catch {
            // Logs the error if camera switching fails.
            print("Error switching cameras: \(error.localizedDescription)")
        }
    }
    
    /// Toggles the camera's flash mode between `.on`, `.off`, and `.auto`.
    public func toggleFlashMode() {
        // Cycles through the flash modes in order.
        switch flashMode {
        case .auto:
            flashMode = .on
        case .on:
            flashMode = .off
        case .off:
            flashMode = .auto
        @unknown default:
            // Ensures compatibility with future flash modes by defaulting to `.auto`.
            flashMode = .auto
        }
    }
    
    /// Starts the camera session on a background thread to prevent blocking the main UI thread.
    public func startSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession?.startRunning()
        }
    }
    
    /// Stops the camera session, freeing up the camera resource.
    public func stopSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession?.stopRunning()
        }
    }
    
    /// Captures a photo and emits the result through a Combine publisher.
    /// - Returns: A publisher that emits the captured `UIImage` or a `CameraServiceError`.
    public func capturePhoto() -> AnyPublisher<UIImage, CameraServiceError> {
        guard let photoOutput = photoOutput else {
            // Emits an error if the photo output is not initialized.
            return Fail(error: CameraServiceError.photoOutputNotInitialized)
                .eraseToAnyPublisher()
        }
        
        // Configures photo capture settings including flash mode.
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .auto
        
        // Initiates photo capture and delegates the result handling.
        photoOutput.capturePhoto(with: settings, delegate: self)
        
        // Returns the Combine publisher that will emit the photo capture result.
        return photoCaptureSubject.eraseToAnyPublisher()
    }
    
    /// Returns the preview layer that displays the camera feed.
    /// - Returns: The `AVCaptureVideoPreviewLayer` associated with the camera session.
    public func getPreviewLayer() -> AVCaptureVideoPreviewLayer? {
        return previewLayer
    }
}

// MARK: - AVCapturePhotoCaptureDelegate

/// Extension of `CameraService` to handle photo capture results.
extension CameraService: AVCapturePhotoCaptureDelegate {
    
    /// Called when the photo capture process finishes, handling success and errors.
    /// - Parameters:
    ///   - output: The `AVCapturePhotoOutput` that captured the photo.
    ///   - photo: The `AVCapturePhoto` object containing the captured image data.
    ///   - error: Any error that occurred during the photo capture process.
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            // Sends an error if the capture failed.
            photoCaptureSubject.send(completion: .failure(.captureFailed(error)))
        } else if let data = photo.fileDataRepresentation(), let image = UIImage(data: data) {
            // Sends the captured image on success.
            photoCaptureSubject.send(image)
            photoCaptureSubject.send(completion: .finished)
        } else {
            // Sends an unknown error if the capture could not produce a valid image.
            photoCaptureSubject.send(completion: .failure(.unknown))
        }
    }
}
