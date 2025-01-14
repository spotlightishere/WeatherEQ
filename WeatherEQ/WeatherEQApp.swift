//
//  WeatherEQApp.swift
//  WeatherEQ
//
//  Created by Spotlight Deveaux on 2025-01-08.
//

import SwiftUI

@main
struct WeatherEQApp: App {
    var body: some Scene {
        DocumentGroup(viewing: TrackDocument.self) { loadedFile in
            TrackDocumentView(file: loadedFile.document.setSourceURL(loadedFile.fileURL!))
            #if os(macOS)
                // Under macOS, SwiftUI allows a very interesting default layout without a minimum set.
                .frame(minWidth: 500.0, minHeight: 500.0)
            #endif
        }
        #if os(macOS)
        // Attempt to avoid having a save button.
        .commands {
            CommandGroup(replacing: .saveItem) {}
        }
        #endif
    }
}
