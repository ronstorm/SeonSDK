//
//  CameraView.swift
//  SeonSDK
//
//  Created by Amit on 17.09.24.
//

import SwiftUI

public struct CameraView: View {
    @StateObject public var viewModel = CameraViewModel()
    public var onCapture: ((UIImage) -> Void)?

    // Dismiss for iOS 15+ using the environment
    @Environment(\.dismiss) private var dismiss

    public init(onCapture: ((UIImage) -> Void)?) {
        self.onCapture = onCapture
    }

    public var body: some View {
        ZStack {
            // Camera preview
            CameraPreviewView(cameraService: viewModel.cameraService)
                .edgesIgnoringSafeArea(.all)
                .onAppear {
                    viewModel.startCamera()
                }
                .onDisappear {
                    viewModel.stopCamera()
                }

            // Close button at the top-left corner
            VStack {
                HStack {
                    Button(action: {
                        dismiss()  // Dismiss the camera view
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                    }
                    Spacer()
                }
                Spacer()
            }

            // Capture, flash, and camera toggle buttons at the bottom
            VStack {
                Spacer()

                // Flash button on the left, Capture button in the center, Camera toggle on the right
                HStack {
                    // Flash button
                    Button(action: {
                        viewModel.toggleFlash()
                    }) {
                        Image(systemName: viewModel.flashIcon)
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }

                    Spacer()

                    // Capture button in the center
                    Button(action: {
                        viewModel.capturePhoto { result in
                            switch result {
                            case .success(let image):
                                onCapture?(image)
                            case .failure(let error):
                                viewModel.errorMessage = error.localizedDescription
                                viewModel.showError = true
                            }
                        }
                    }) {
                        // Circular button styling
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.6)) // Inner circle, semi-transparent
                                .frame(width: 65, height: 65)

                            Circle()
                                .stroke(Color.white, lineWidth: 6) // Outer circle
                                .frame(width: 75, height: 75)
                        }
                    }
                    .disabled(!viewModel.isCameraReady)

                    Spacer()

                    // Camera toggle button on the right
                    Button(action: {
                        viewModel.switchCamera()
                    }) {
                        Image(systemName: "arrow.triangle.2.circlepath.camera")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 30)  // Spacing between buttons
                .padding(.bottom, 40)  // Bottom padding
            }
        }
        .alert(isPresented: $viewModel.showError) {
            Alert(title: Text("Error"), message: Text(viewModel.errorMessage), dismissButton: .default(Text("OK")))
        }
    }
}
