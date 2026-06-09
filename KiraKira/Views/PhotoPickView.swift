//
//  PhotoPickView.swift
//  KiraKira
//
//  Created by 大場史温 on 2026/06/09.
//

import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct PhotoPickView: UIViewControllerRepresentable {
    @Binding var imageData: UIImage?
    @Binding var location: CLLocation?
    @Environment(\.dismiss) private var dismiss
    let onSelected: () -> Void

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.filter = .images
        configuration.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoPickView

        init(parent: PhotoPickView) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.dismiss()

            guard let result = results.first else { return }

            // 1. Try to get location from PHAsset (Requires Photo Library permission)
            if let assetId = result.assetIdentifier {
                let assetResults = PHAsset.fetchAssets(withLocalIdentifiers: [assetId], options: nil)
                if let asset = assetResults.firstObject {
                    if let assetLocation = asset.location {
                        parent.location = assetLocation
                    }
                }
            }

            // 2. Load the image and attempt to get Exif if location is still nil
            let provider = result.itemProvider
            if provider.canLoadObject(ofClass: UIImage.self) {
                // If we don't have location yet, try to load data representation to get Exif
                if parent.location == nil {
                    provider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier) { [weak self] (url, error) in
                        if let url = url, let data = try? Data(contentsOf: url) {
                            let extractedLocation = UIImage.extractLocation(from: data)
                            DispatchQueue.main.async {
                                self?.parent.location = extractedLocation
                            }
                        }
                    }
                }

                provider.loadObject(ofClass: UIImage.self) { [weak self] (image, error) in
                    if let image = image as? UIImage {
                        DispatchQueue.main.async {
                            self?.parent.imageData = image
                            self?.parent.onSelected()
                        }
                    }
                }
            }
        }
    }
}
