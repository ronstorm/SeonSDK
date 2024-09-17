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
    
    private var cancellables = Set<AnyCancellable>()
    
    public var cameraService: CameraServiceProvider
    
    public init(cameraService: CameraServiceProvider = CameraService()) {
        self.cameraService = cameraService
    }
    
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
    
    // This method will initiate the photo capture and handle the response
    public func capturePhoto() {
        cameraService.capturePhoto()
            .sink { completion in
                if case .failure(let error) = completion {
                    DispatchQueue.main.async {
                        self.errorMessage = error.localizedDescription
                        self.showError = true
                    }
                }
            } receiveValue: { image in
                DispatchQueue.main.async {
                    self.capturedImage = image
                }
            }
            .store(in: &cancellables)
    }
}
