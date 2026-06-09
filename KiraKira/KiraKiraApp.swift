//
//  KiraKiraApp.swift
//  KiraKira
//
//  Created by 大場史温 on 2026/06/09.
//

import SwiftUI
import SwiftData

@main
struct KiraKiraApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: StickerModel.self)
    }
}
