//
//  CameraPreviewView.swift
//  SeonSDK
//
//  Created by Amit on 17.09.24.
//

import SwiftUI
import AVFoundation

/// `CameraPreviewView` is a SwiftUI wrapper around a UIKit view that displays the camera's live feed.
/// It uses `UIViewRepresentable` to bridge UIKit's `UIView` and SwiftUI's declarative interface.
/// The preview layer provided by the camera service is embedded in this view to show the camera output.
struct CameraPreviewView: UIViewRepresentable {
    
    /// A reference to the camera service, providing access to the camera's preview layer.
    let cameraService: CameraServiceProvider

    /// Creates the `UIView` instance that will be used as the camera preview in SwiftUI.
    /// - Parameter context: The context object containing information about the current state of the system.
    /// - Returns: A `UIView` configured to display the camera's live feed.
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero) // Initializes an empty UIView.
        
        // Sets up the camera preview layer provided by the camera service.
        if let previewLayer = cameraService.getPreviewLayer() {
            // Configures the preview layer to fill the view and maintain the aspect ratio.
            previewLayer.frame = view.bounds
            previewLayer.videoGravity = .resizeAspectFill
            
            // Adds the preview layer as a sublayer of the view, displaying the camera feed.
            view.layer.addSublayer(previewLayer)
        }
        
        return view
    }

    /// Updates the `UIView` when SwiftUI detects a state change that requires a redraw.
    /// - Parameters:
    ///   - uiView: The `UIView` instance currently being displayed.
    ///   - context: The context object containing information about the current state of the system.
    func updateUIView(_ uiView: UIView, context: Context) {
        // Adjusts the frame of the camera preview layer to match the current size of the SwiftUI view.
        if let previewLayer = cameraService.getPreviewLayer() {
            DispatchQueue.main.async {
                // Ensures the preview layer is resized to fit the updated bounds of the UI view.
                previewLayer.frame = uiView.bounds
            }
        }
    }
}
