//
//  Photo.swift
//  SeonSDK
//
//  Created by Amit on 18.09.24.
//

import UIKit.UIImage

// Wrapper for UIImage to make it Identifiable
struct Photo: Identifiable {
    let id = UUID()  // Unique identifier
    let image: UIImage
}
