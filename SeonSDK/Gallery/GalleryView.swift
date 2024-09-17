//
//  GalleryView.swift
//  SeonSDK
//
//  Created by Amit on 17.09.24.
//

import SwiftUI

struct GalleryView: View {
    @StateObject var viewModel = GalleryViewModel()
    @State private var selectedPhoto: Photo? = nil  // Controls the full-screen presentation
    
    // Calculating the dynamic number of columns based on screen width
    private var columns: [GridItem] {
        let screenWidth = UIScreen.main.bounds.width
        let spacing: CGFloat = 16.0
        let itemWidth: CGFloat = 100  // Width of each photo
        let numberOfColumns = Int((screenWidth - spacing) / (itemWidth + spacing))
        
        return Array(repeating: GridItem(.flexible(), spacing: spacing), count: numberOfColumns)
    }
    
    var body: some View {
        VStack(spacing: 10) {
            // Title and Subtitle
            VStack(spacing: 4) {
                Text("Photos")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("\(viewModel.photos.count) \(viewModel.photos.count == 1 ? "Photo" : "Photos")")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(.top, 20)
            
            // Photo Grid
            if viewModel.photos.isEmpty {
                Text("No photos available")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(viewModel.photos) { photo in
                            Image(uiImage: photo.image)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 100)
                                .cornerRadius(10)
                                .clipped()  // Ensures the image stays within bounds
                                .onTapGesture {
                                    selectedPhoto = photo  // Select the photo for modal presentation
                                }
                                .contextMenu {
                                    Button(role: .destructive) {
                                        withAnimation {
                                            if let index = viewModel.photos.firstIndex(where: { $0.id == photo.id }) {
                                                viewModel.deletePhoto(at: index)
                                            }
                                        }
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                    
                                    Button("Cancel", role: .cancel) {}
                                }

                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                }
            }
            
            // Caption at the bottom
            Text("Long press to delete a photo")
                .font(.footnote)
                .foregroundColor(.gray)
                .padding(.top, 10)
        }
        .navigationBarTitle("Gallery", displayMode: .inline)
        .onAppear {
            viewModel.loadPhotos()
        }
        .sheet(item: $selectedPhoto) { photo in
            FullScreenPhotoView(photo: photo.image)
        }
    }
}
