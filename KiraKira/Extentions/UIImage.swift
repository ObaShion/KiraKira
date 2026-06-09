//
//  UIImage.swift
//  KiraKira
//
//  Created by 大場史温 on 2026/06/09.
//

import Foundation
import UIKit
import CoreLocation
import ImageIO

extension UIImage {
    static func extractLocation(from data: Data) -> CLLocation? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
        guard let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String: Any] else { return nil }
        guard let gpsData = properties[kCGImagePropertyGPSDictionary as String] as? [String: Any] else { return nil }

        guard let latitudeRef = gpsData[kCGImagePropertyGPSLatitudeRef as String] as? String,
              let latitude = gpsData[kCGImagePropertyGPSLatitude as String] as? Double,
              let longitudeRef = gpsData[kCGImagePropertyGPSLongitudeRef as String] as? String,
              let longitude = gpsData[kCGImagePropertyGPSLongitude as String] as? Double else {
            return nil
        }

        let finalLatitude = (latitudeRef == "S") ? -latitude : latitude
        let finalLongitude = (longitudeRef == "W") ? -longitude : longitude

        return CLLocation(latitude: finalLatitude, longitude: finalLongitude)
    }

    func extractLocation() -> CLLocation? {
        guard let data = self.jpegData(compressionQuality: 1.0) else { return nil }

        return UIImage.extractLocation(from: data)
    }
}
