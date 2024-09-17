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
            
            // Flash and camera switch buttons at the top
            VStack {
                HStack {
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
                    .padding(.leading, 16)

                    Spacer()

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
                    .padding(.trailing, 16)
                }
                Spacer()

                // Capture button at the bottom
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
                    Text("Capture Photo")
                        .foregroundColor(.white)
                        .padding()
                        .background(viewModel.isCameraReady ? Color.blue : Color.gray)
                        .cornerRadius(10)
                }
                .padding()
                .disabled(!viewModel.isCameraReady)
            }
        }
        .alert(isPresented: $viewModel.showError) {
            Alert(title: Text("Error"), message: Text(viewModel.errorMessage), dismissButton: .default(Text("OK")))
        }
    }
}
