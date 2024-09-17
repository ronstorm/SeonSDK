//
//  CameraService.swift
//  SeonSDK
//
//  Created by Amit on 15.09.24.
//

import AVFoundation
import UIKit.UIImage
import Combine

public class CameraService: NSObject, CameraServiceProvider {
    private var captureSession: AVCaptureSession?
    private var currentCamera: AVCaptureDevice?
    private var frontCamera: AVCaptureDevice?
    private var rearCamera: AVCaptureDevice?
    private var photoOutput: AVCapturePhotoOutput?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var completion: ((Result<UIImage, Error>) -> Void)?
    
    public var flashMode: AVCaptureDevice.FlashMode = .auto
    
    private var photoCaptureSubject = PassthroughSubject<UIImage, CameraServiceError>()
    
    public override init() {
        super.init()
        setupSession()
    }
    
    // Set up the camera session and preview layer
    public func setupSession() {
        captureSession = AVCaptureSession()
        setupCameras()
        
        // Use the front camera by default
        if let camera = frontCamera {
            switchToCamera(camera)
        }
        
        // Initialize photo output
        photoOutput = AVCapturePhotoOutput()
        if let photoOutput = photoOutput {
            captureSession?.addOutput(photoOutput)
        }
        
        // Set up the preview layer
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        previewLayer?.videoGravity = .resizeAspectFill
    }
    
    // Configure front and rear cameras
    private func setupCameras() {
        frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
        rearCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
    }
    
    // Switch between front and rear cameras
    public func switchCamera() {
        guard let session = captureSession else { return }
        
        session.beginConfiguration()
        
        // Remove the existing input
        if let currentInput = session.inputs.first as? AVCaptureDeviceInput {
            session.removeInput(currentInput)
        }
        
        // Switch to the other camera
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
    
    // Helper to switch the camera
    private func switchToCamera(_ camera: AVCaptureDevice) {
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            captureSession?.addInput(input)
            currentCamera = camera
        } catch {
            print("Error switching cameras: \(error.localizedDescription)")
        }
    }
    
    // Toggle flash between .on, .off, and .auto
    public func toggleFlashMode() {
        switch flashMode {
        case .auto:
            flashMode = .on
        case .on:
            flashMode = .off
        case .off:
            flashMode = .auto
        @unknown default:
            flashMode = .auto
        }
    }
    
    public func startSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession?.startRunning()
        }
    }
    
    public func stopSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession?.stopRunning()
        }
    }
    
    // Capture a photo and return as AnyPublisher
    public func capturePhoto() -> AnyPublisher<UIImage, CameraServiceError> {
        guard let photoOutput = photoOutput else {
            return Fail(error: CameraServiceError.photoOutputNotInitialized)
                .eraseToAnyPublisher()
        }
        
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .auto
        photoOutput.capturePhoto(with: settings, delegate: self)
        
        // Return the Combine publisher
        return photoCaptureSubject.eraseToAnyPublisher()
    }
    
    // Return the camera preview layer to display the live feed
    public func getPreviewLayer() -> AVCaptureVideoPreviewLayer? {
        return previewLayer
    }
}

extension CameraService: AVCapturePhotoCaptureDelegate {
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            photoCaptureSubject.send(completion: .failure(.captureFailed(error)))
        } else if let data = photo.fileDataRepresentation(), let image = UIImage(data: data) {
            photoCaptureSubject.send(image)
            photoCaptureSubject.send(completion: .finished)
        } else {
            photoCaptureSubject.send(completion: .failure(.unknown))
        }
    }
}
