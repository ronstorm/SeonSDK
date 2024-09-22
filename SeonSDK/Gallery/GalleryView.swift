//
//  GalleryView.swift
//  SeonSDK
//
//  Created by Amit on 17.09.24.
//

import SwiftUI

/// `GalleryView` is a SwiftUI view that displays a grid of photos managed by the `GalleryViewModel`.
/// Users can view photos, delete them using a context menu, and tap to view photos in full-screen mode.
struct GalleryView: View {
    
    /// The view model that manages the state and logic for the gallery.
    @StateObject var viewModel = GalleryViewModel()
    
    /// Dynamically calculates the number of columns for the grid based on screen width.
    /// Ensures that the grid layout adapts to different screen sizes.
    private var columns: [GridItem] {
        let screenWidth = UIScreen.main.bounds.width
        let spacing: CGFloat = 16.0
        let itemWidth: CGFloat = 100  // Width of each photo item.
        // Calculates the number of columns based on available width and spacing.
        let numberOfColumns = Int((screenWidth - spacing) / (itemWidth + spacing))
        
        // Creates an array of flexible grid items with the calculated column count.
        return Array(repeating: GridItem(.flexible(), spacing: spacing), count: numberOfColumns)
    }
    
    /// The main body of the `GalleryView`, defining the layout and components.
    var body: some View {
        VStack(spacing: 10) {
            // Title and subtitle showing the total number of photos.
            VStack(spacing: 4) {
                Text("Photos")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("\(viewModel.photos.count) \(viewModel.photos.count == 1 ? "Photo" : "Photos")")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(.top, 20)
            
            // Displays a message if there are no photos to show.
            if viewModel.photos.isEmpty {
                Text("No photos available")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                // Photo grid view using a scrollable grid layout.
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        // Iterates over each photo to create individual grid items.
                        ForEach(viewModel.photos) { photo in
                            Image(uiImage: photo.image)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 100)  // Sets the height of each photo item.
                                .cornerRadius(10)
                                .clipped() // Ensures the image does not overflow the bounds.
                                .onTapGesture {
                                    viewModel.selectPhoto(photo) // Select the photo for modal presentation
                                }
                                .contextMenu {
                                    // Context menu with options like delete and cancel.
                                    Button(role: .destructive) {
                                        withAnimation {
                                            // Finds the index of the selected photo and deletes it.
                                            if let index = viewModel.photos.firstIndex(where: { $0.id == photo.id }) {
                                                viewModel.deletePhoto(at: index)
                                            }
                                        }
                                    } label: {
                                        Label("Delete", systemImage: "trash") // Delete button with a trash icon.
                                    }
                                    
                                    Button("Cancel", role: .cancel) {} // Cancel button in the context menu.
                                }
                        }
                    }
                    .padding(.horizontal, 16) // Horizontal padding around the grid.
                    .padding(.top, 10) // Top padding to space the grid from the title section.
                }
            }
            
            // Caption at the bottom to guide the user about the long press action.
            Text("Long press to delete a photo")
                .font(.footnote)
                .foregroundColor(.gray)
                .padding(.top, 10)
        }
        .navigationBarTitle("Gallery", displayMode: .inline) // Sets the navigation title.
        .onAppear {
            viewModel.loadPhotos() // Loads photos when the view appears.
        }
        .sheet(item: $viewModel.selectedPhoto) { photo in
            // Presents the selected photo in full-screen when tapped.
            FullScreenPhotoView(photo: photo.image)
                .onDisappear {
                    // Clear the selection when the full-screen view is dismissed
                    viewModel.clearSelectedPhoto()
                }
        }
        // Error handling: Show alert when there's an error message
        .alert(isPresented: $viewModel.showError) {
            Alert(
                title: Text("Error"),
                message: Text(viewModel.errorMessage ?? "An unknown error occurred."),
                dismissButton: .default(Text("OK")) {
                    viewModel.showError = false
                }
            )
        }
    }
}
