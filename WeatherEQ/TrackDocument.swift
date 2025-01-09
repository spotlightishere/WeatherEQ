//
//  TrackDocument.swift
//  WeatherEQ
//
//  Created by Spotlight Deveaux on 2025-01-09.
//

import AVFoundation
import Foundation
import SwiftUI
import UniformTypeIdentifiers

/// The primary track document used to load an asset. It should be considered read-only.
class TrackDocument: FileDocument {
    // We will attempt to support any audio type.
    static var readableContentTypes: [UTType] = [.audio]
    // We do not want to saving as we are read-only.
    static var writableContentTypes: [UTType] = []

    // Our opened file URL.
    var sourceURL: URL?

    required init(configuration _: ReadConfiguration) throws {
        // We're all done here - our file URL was given to TrackDocumentView.
    }

    func fileWrapper(configuration _: WriteConfiguration) throws -> FileWrapper {
        // We do not support saving.
        throw CocoaError(.fileWriteNoPermission)
    }

    // https://stackoverflow.com/a/74118731
    func setSourceURL(_ fileURL: URL) -> TrackDocument {
        sourceURL = fileURL
        return self
    }
}

struct TrackDocumentView: View {
    var file: TrackDocument
    @StateObject var currentTrack = PlayingTrack()

    // This is rather jank...
    @State private var trackLoaded = false
    @State private var errorText = ""

    // Mock values.
    @State private var lol = 0
    @State private var eqEntries: [[Float]] = [[
        0.45,
        0.45,
        0.45,
        0.40,
        0.40,
        0.40,
        0.35,
        0.35,
        0.35,
        0.35,
        0.30,
        0.30,
        0.25,
        0.25,
        0.20,
    ]]

    var body: some View {
        if trackLoaded {
            // Vaguely simulate what the widget looks like.
            VStack {
                WeatherView(eqEntries: eqEntries[lol])
                    // Some padding appears to be added by the system.
                    .padding(2)
                    .background(Color(red: 0.36, green: 0.44, blue: 0.54).gradient)
                    .cornerRadius(24)
            }.onAppear {
                Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                    lol = lol + 1
                    print("heyy")
                    print("current: \(eqEntries[lol])")
                }
            }
        } else if errorText != "" {
            Text(errorText)
                .padding()
        } else {
            ProgressView("Loading track...")
                .task {
                    do {
                        eqEntries = try await currentTrack.load(assetPath: file.sourceURL!)
                        trackLoaded = true
                    } catch let e {
                        print("Encountered exception while loading track: \(e)")
                        errorText = "An error occurred while loading: \(e)"
                    }
                }
                .padding()
        }
    }
}
