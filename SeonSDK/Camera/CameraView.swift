//
//  CameraView.swift
//  SeonSDK
//
//  Created by Amit on 17.09.24.
//

import SwiftUI

/// `CameraView` is the main SwiftUI view for capturing photos. It integrates the camera preview,
/// camera controls (flash, capture, toggle camera), and handles user interactions such as dismissing the view.
/// It uses a `CameraViewModel` to manage camera states and actions.
public struct CameraView: View {
    
    /// The view model managing the camera state and actions, observed for state changes.
    @StateObject public var viewModel = CameraViewModel()
    
    /// Callback function to return the captured image to the parent view.
    public var onCapture: ((UIImage) -> Void)?

    /// Environment variable to manage dismissing the view.
    @Environment(\.dismiss) private var dismiss

    /// Initializes the `CameraView` with an optional capture callback.
    /// - Parameter onCapture: A closure that is called with the captured image when the photo is taken.
    public init(onCapture: ((UIImage) -> Void)?) {
        self.onCapture = onCapture
    }

    /// The body of the SwiftUI view, defining the layout and components.
    public var body: some View {
        ZStack {
            // Camera preview using the `CameraPreviewView`.
            CameraPreviewView(cameraService: viewModel.cameraService)
                .edgesIgnoringSafeArea(.all) // Ensures the camera preview covers the entire screen.
                .onAppear {
                    viewModel.startCamera() // Starts the camera session when the view appears.
                }
                .onDisappear {
                    viewModel.stopCamera() // Stops the camera session when the view disappears.
                }

            // Close button positioned at the top-left corner.
            VStack {
                HStack {
                    Button(action: {
                        dismiss()  // Dismiss the camera view when the button is tapped.
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

            // Capture, flash, and camera toggle buttons positioned at the bottom of the view.
            VStack {
                Spacer()

                // Button layout: Flash on the left, Capture in the center, and Toggle Camera on the right.
                HStack {
                    // Flash toggle button.
                    Button(action: {
                        viewModel.toggleFlash() // Toggles the flash mode when tapped.
                    }) {
                        Image(systemName: viewModel.flashIcon)
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle()) // Circular button style with semi-transparent background.
                    }

                    Spacer()

                    // Capture button in the center, styled with concentric circles.
                    Button(action: {
                        viewModel.capturePhoto() // Initiates photo capture via the view model.
                    }) {
                        // Inner and outer circular design for the capture button.
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.6)) // Inner circle, semi-transparent white.
                                .frame(width: 65, height: 65)

                            Circle()
                                .stroke(Color.white, lineWidth: 6) // Outer ring around the button.
                                .frame(width: 75, height: 75)
                        }
                    }
                    .disabled(!viewModel.isCameraReady) // Disables the capture button until the camera is ready.

                    Spacer()

                    // Camera switch button to toggle between front and rear cameras.
                    Button(action: {
                        viewModel.switchCamera() // Switches between the front and rear cameras.
                    }) {
                        Image(systemName: "arrow.triangle.2.circlepath.camera")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle()) // Circular button style with semi-transparent background.
                    }
                }
                .padding(.horizontal, 30) // Horizontal padding between the buttons.
                .padding(.bottom, 40) // Bottom padding to space the buttons from the edge.
            }
        }
        // Displays an alert if there is an error during photo capture.
        .alert(isPresented: $viewModel.showError) {
            Alert(
                title: Text("Error"),
                message: Text(viewModel.errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        // Observes changes to the captured image and triggers the capture callback when a photo is taken.
        .onChange(of: viewModel.capturedImage) { image in
            if let image = image {
                onCapture?(image) // Calls the provided callback with the captured image.
            }
        }
    }
}
