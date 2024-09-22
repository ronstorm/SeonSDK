# SeonSDK (iOS)

### Capture, Store, and View Photos with Ease 📸

**SeonSDK** is a lightweight, easy-to-integrate framework for iOS that provides seamless functionalities to capture photos, store them securely, and view them in a beautifully designed gallery. With built-in biometric authentication, you can ensure that only authorized users can access stored photos.

## Objective

The objective of **SeonSDK** is to provide a simplified and unified interface for photo management within iOS applications, allowing developers to quickly integrate camera functionalities, secure photo storage, and access with user authentication using Face ID or Touch ID.

## How to Integrate in Your Application

To integrate **SeonSDK** into your iOS application, follow these simple steps:

1. **Drag and Drop the Framework**: Download the [SeonSDK Framework](https://github.com/ronstorm/seonsdk-libraries/tree/master/iOS) and drag and drop it into your Xcode project under the app's root folder.

2. **Add the Framework to Your Target**:
   - Go to your project settings in Xcode.
   - Under **General**, scroll to the **Frameworks, Libraries, and Embedded Content** section.
   - Click the `+` button, select **SeonSDK.framework**, and set it to **Embed & Sign**.

3. **Update `info.plist` for Camera Privacy**:
   - Add the following key to request permission for the camera:
     ```xml
     <key>NSCameraUsageDescription</key>
     <string>We need access to the camera to take photos.</string>
     ```

4. **Update `info.plist` for Face ID Privacy**:
   - Add the following key to request permission for biometric authentication:
     ```xml
     <key>NSFaceIDUsageDescription</key>
     <string>We use Face ID to protect your photos.</string>
     ```

## Usage

Below is a quick guide on how to use **SeonSDK** in your application:

```swift
// Import the framework
import SeonSDK

// Initialize PhotoSDK
private let photoSDK = PhotoSDK()

// Get the camera view with this method call
photoSDK.takePhoto { result in
    switch result {
    case .success(let image):
        // Handle the captured image
        print("Captured image: \(image)")
    case .failure(let error):
        // Handle errors
        print("Error capturing photo: \(error.localizedDescription)")
    }
}

// Get the gallery view with this method call
photoSDK.accessPhotos { result in
    switch result {
    case .success(let galleryView):
        // Display the gallery view
        print("Gallery accessed successfully.")
    case .failure(let error):
        // Handle errors
        print("Error accessing gallery: \(error.localizedDescription)")
    }
}
```

## Sample Application

To see **SeonSDK** in action, check out the [sample application](https://github.com/ronstorm/seonsdk-ios-app) that demonstrates the full capabilities of the framework. This sample app shows how to integrate and utilize the SDK for photo capture, storage, and gallery access.


## Conclusion

**SeonSDK** aims to simplify photo management in iOS applications, providing a clean and intuitive interface for developers. We welcome feedback and contributions to help improve the framework. If you encounter any issues or have suggestions, feel free to open an issue or submit a pull request on GitHub.

Thank you for using **SeonSDK**! 🚀
