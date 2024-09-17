//
//  FullScreenPhotoView.swift
//  SeonSDK
//
//  Created by Amit on 17.09.24.
//

import SwiftUI

struct FullScreenPhotoView: View {
    let photo: UIImage

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)  // Background color for fullscreen view
            Image(uiImage: photo)
                .resizable()
                .scaledToFit()
                .edgesIgnoringSafeArea(.all)
        }
    }
}
