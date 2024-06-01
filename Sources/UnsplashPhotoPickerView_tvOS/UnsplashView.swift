//
//  UnsplashView.swift
//
//
//  Created by takedatakashiki on 2023/12/28.
//

import SwiftUI
import UnsplashPhotoPicker
import UnsplashPhotoPickerUI_tvOS

public struct UnsplashView: UIViewControllerRepresentable {
    public typealias UIViewControllerType = UIViewController
    
    private let accessKey: String
    private let secretKey: String
    
    private let query: String
    @Binding var image: UIImage?
    @Binding var imageURL: URL?
    @Binding var userName: String?
    
    public init(
        accessKey: String,
        secretKey: String,
        query: String,
        image: Binding<UIImage?>,
        imageURL: Binding<URL?>,
        userName: Binding<String?>
    ) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.query = query
        self._image = image
        self._imageURL = imageURL
        self._userName = userName
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(
            image: $image,
            imageURL: $imageURL,
            userName: $userName
        )
    }
    
    public func makeUIViewController(context: Context) -> UIViewController {
        let configuration = UnsplashPhotoPickerConfiguration(
            photoViewNib: UnsplashPhotoPickerUI_tvOS.photoViewNib,
            accessKey: accessKey,
            secretKey: secretKey,
            query: query
        )
        let unsplashPhotoPicker = UnsplashPhotoPicker(configuration: configuration)
        unsplashPhotoPicker.photoPickerDelegate = context.coordinator
        return unsplashPhotoPicker
    }
    
    public func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    }
    
    public class Coordinator: NSObject, UnsplashPhotoPickerDelegate {
        @Binding var image: UIImage?
        @Binding var imageURL: URL?
        @Binding var userName: String?

        init(
            image: Binding<UIImage?>,
            imageURL: Binding<URL?>,
            userName: Binding<String?>
        ) {
            self._image = image
            self._imageURL = imageURL
            self._userName = userName
        }
        
        public func unsplashPhotoPicker(_ photoPicker: UnsplashPhotoPicker, didSelectPhotos photos: [UnsplashPhoto]) {
            guard let photo = photos.first else { return }
            Task {
                let url = photo.urls[.regular]
                let result = await PhotoDownloader.downloadPhoto(url: url)
                Task { @MainActor in
                    image = result
                    imageURL = url
                    userName = photo.user.username
                }
            }
        }
        
        public func unsplashPhotoPickerDidCancel(_ photoPicker: UnsplashPhotoPicker) {
        }
    }
}

struct PhotoDownloader {
    private static var cache: URLCache = {
        let memoryCapacity = 50 * 1024 * 1024
        let diskCapacity = 100 * 1024 * 1024
        let diskPath = "unsplash"
        
        if #available(iOS 13.0, *) {
            return URLCache(
                memoryCapacity: memoryCapacity,
                diskCapacity: diskCapacity,
                directory: URL(fileURLWithPath: diskPath, isDirectory: true)
            )
        }
        else {
            #if !targetEnvironment(macCatalyst)
            return URLCache(
                memoryCapacity: memoryCapacity,
                diskCapacity: diskCapacity,
                diskPath: diskPath
            )
            #else
            fatalError()
            #endif
        }
    }()

    static func downloadPhoto(url: URL?) async -> UIImage? {
        guard let url else { return nil }

        if let cachedResponse = Self.cache.cachedResponse(for: URLRequest(url: url)),
            let image = UIImage(data: cachedResponse.data) {
            return image
        }
        
        let result: (data: Data, response: URLResponse)? = try? await URLSession.shared.data(from: url)
        guard let result else { return nil }
        
        Self.cache.storeCachedResponse(
            CachedURLResponse(response: result.response, data: result.data),
            for: URLRequest(url: url)
        )
        
        return UIImage(data: result.data)
    }
}
