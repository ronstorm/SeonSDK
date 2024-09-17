//
//  CameraViewModel.swift
//  SeonSDK
//
//  Created by Amit on 17.09.24.
//

import Combine
import UIKit.UIImage

public class CameraViewModel: ObservableObject {
    @Published public var capturedImage: UIImage?
    @Published public var showError: Bool = false
    @Published public var errorMessage: String = ""
    @Published public var isCameraReady: Bool = false

    public var cameraService = CameraService()

    public var flashIcon: String {
        switch cameraService.flashMode {
        case .auto:
            return "bolt.badge.a.fill"
        case .on:
            return "bolt.fill"
        case .off:
            return "bolt.slash.fill"
        @unknown default:
            return "bolt.slash.fill"
        }
    }

    public init() {}

    public func startCamera() {
        cameraService.startSession()
        isCameraReady = true
    }

    public func stopCamera() {
        cameraService.stopSession()
        isCameraReady = false
    }

    public func toggleFlash() {
        cameraService.toggleFlashMode()
        objectWillChange.send() // Force a UI update for the flash icon
    }

    public func switchCamera() {
        cameraService.switchCamera()
    }

    public func capturePhoto(completion: @escaping (Result<UIImage, Error>) -> Void) {
        cameraService.capturePhoto { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let image):
                    self.capturedImage = image
                    completion(.success(image))
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                    completion(.failure(error))
                }
            }
        }
    }
}
