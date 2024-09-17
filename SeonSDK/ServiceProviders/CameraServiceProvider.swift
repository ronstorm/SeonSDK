//
//  CameraServiceProvider.swift
//  SeonSDK
//
//  Created by Amit on 15.09.24.
//

import UIKit.UIImage
import Combine
import AVFoundation

public protocol CameraServiceProvider {
    func capturePhoto() -> AnyPublisher<UIImage, CameraServiceError>
    func startSession()
    func stopSession()
    func toggleFlashMode()
    func switchCamera()
    func getPreviewLayer() -> AVCaptureVideoPreviewLayer?
    
    var flashMode: AVCaptureDevice.FlashMode { get }
}

public enum CameraServiceError: Error, LocalizedError {
    case photoOutputNotInitialized
    case captureFailed(Error)
    case unknown
    
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
