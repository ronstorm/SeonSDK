//
//  GalleryView.swift
//  SeonSDK
//
//  Created by Amit on 17.09.24.
//

import SwiftUI

struct GalleryView: View {
    @StateObject var viewModel = GalleryViewModel()
    let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
    
    var body: some View {
        VStack {
            if viewModel.photos.isEmpty {
                Text("No photos available")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(viewModel.photos.indices, id: \.self) { index in
                            if let photo = viewModel.photos[safe: index] {
                                Image(uiImage: photo)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 100)
                                    .cornerRadius(10)
                                    .onTapGesture {
                                        withAnimation {
                                            viewModel.deletePhoto(at: index)
                                        }
                                    }
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationBarTitle("Gallery", displayMode: .inline)
        .onAppear {
            viewModel.loadPhotos()
        }
    }
}

// Safe array indexing extension to avoid crashes
extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
