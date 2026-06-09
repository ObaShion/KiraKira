//
//  StickerModel.swift
//  KiraKira
//
//  Created by 大場史温 on 2026/06/09.
//

import Foundation
import MapKit
import SwiftData
import UIKit

@Model
final class StickerModel: Identifiable {
    var id = UUID()
    var title: String
    var rawImageData: Data
    var latitude: Double
    var longitude: Double
    var timestamp: Date

    init(title: String, image: UIImage, location: CLLocation) {
        self.title = title
        self.rawImageData = image.pngData() ?? Data()
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        self.timestamp = Date()
    }

    @Transient
    var image: UIImage? {
        UIImage(data: rawImageData)
    }

    @Transient
    var location: CLLocation {
        CLLocation(latitude: latitude, longitude: longitude)
    }
}
