//
//  CameraPreviewView.swift
//  SeonSDK
//
//  Created by Amit on 17.09.24.
//

import SwiftUI
import AVFoundation

struct CameraPreviewView: UIViewRepresentable {
    var cameraService: CameraService

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        
        // Set up the camera preview layer
        if let previewLayer = cameraService.getPreviewLayer() {
            previewLayer.frame = view.bounds
            previewLayer.videoGravity = .resizeAspectFill
            view.layer.addSublayer(previewLayer)
        }
        
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // Update the camera preview layer size
        if let previewLayer = cameraService.getPreviewLayer() {
            DispatchQueue.main.async {
                previewLayer.frame = uiView.bounds
            }
        }
    }
}
