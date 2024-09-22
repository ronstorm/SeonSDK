//
//  FullScreenPhotoView.swift
//  SeonSDK
//
//  Created by Amit on 17.09.24.
//

import SwiftUI

/// `FullScreenPhotoView` is a SwiftUI view that displays a given photo in full-screen mode.
/// It provides an immersive viewing experience with a dark background, allowing the photo to be the focal point.
struct FullScreenPhotoView: View {
    
    /// The photo to be displayed in full-screen mode, passed as a `UIImage`.
    let photo: UIImage

    /// The main body of the `FullScreenPhotoView`, defining the layout and appearance of the full-screen photo view.
    var body: some View {
        ZStack {
            // Sets the background color to black to create a dark, distraction-free environment for viewing the photo.
            Color.black.edgesIgnoringSafeArea(.all)
            
            // Displays the photo using a SwiftUI `Image` view, configured to resize and fit within the screen bounds.
            Image(uiImage: photo)
                .resizable()             // Makes the image resizable to fit the screen.
                .scaledToFit()           // Scales the image proportionally to fit within the view while maintaining aspect ratio.
                .edgesIgnoringSafeArea(.all) // Ensures the image extends to the edges, providing a true full-screen experience.
        }
    }
}
