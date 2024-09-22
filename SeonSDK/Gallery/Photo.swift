//
//  Photo.swift
//  SeonSDK
//
//  Created by Amit on 18.09.24.
//

import UIKit.UIImage

/// `Photo` is a simple struct that wraps a `UIImage` to make it conform to the `Identifiable` protocol.
/// This allows each photo to be uniquely identified in SwiftUI views, enabling seamless integration in lists and grids.
struct Photo: Identifiable {
    
    /// A unique identifier for each `Photo` instance, generated automatically using `UUID`.
    let id = UUID()
    
    /// The `UIImage` that this struct wraps, representing the photo to be displayed.
    let image: UIImage
}
