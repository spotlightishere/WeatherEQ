//
//  PlayingTrack.swift
//  WeatherEQ
//
//  Created by Spotlight Deveaux on 2025-01-09.
//

import Accelerate
import Algorithms
import AVFoundation
import Foundation
import SwiftUI

/// The initial vocal level we want to begin with.
enum PlaybackDefaults {
    public static let initialVocalLevel: Float32 = 85.0
}

@MainActor class PlayingTrack: ObservableObject {
    public var playerItem: AVPlayerItem?
    let audioEngine = AVAudioEngine()

    /// Fully loads the given asset.
    ///
    /// Largely derived from https://developer.apple.com/documentation/avfaudio/audio_engine/performing_offline_audio_processing#3405344.
    /// - Parameter assetPath: The URL to load as audio.
    func load(assetPath: URL) async throws -> [[Float]] {
        let sourceFile = try AVAudioFile(forReading: assetPath)
        let sourceFormat = sourceFile.processingFormat
        let sourceDuration = sourceFile.length
        let sourceFreq = Int64(sourceFormat.sampleRate)
        print("source frame count: \(sourceDuration)")
        print("source frequency: \(sourceFreq)")

        // We effectively want to process all the frames that'd equate to a single second.
        // This is.. not precise, but it's math-y enough.
        // Apologies to anyone who actually knows what they're doing :)
        let framesPerSecond = sourceDuration / sourceFreq
        print("determined duration: \(framesPerSecond)")

        // Create an engine for processing.
        let engine = AVAudioEngine()
        let player = AVAudioPlayerNode()
        let reverb = AVAudioUnitReverb()

        engine.attach(player)
        engine.attach(reverb)

        // Set the desired reverb parameters.
        reverb.loadFactoryPreset(.mediumHall)
        reverb.wetDryMix = 50

        // Connect the nodes.
        engine.connect(player, to: reverb, format: sourceFormat)
        engine.connect(reverb, to: engine.mainMixerNode, format: sourceFormat)

        print("heck!")

        // Schedule the source file.
        player.scheduleFile(sourceFile, at: nil, completionHandler: nil)
        print("ooh")

        // Enable offline rendering so we can immediately sample.
        let maxFrames = AVAudioFrameCount(sourceFreq)
        try engine.enableManualRenderingMode(.offline, format: sourceFormat,
                                             maximumFrameCount: maxFrames)

        try engine.start()
        print("ooh")

        player.play()
        print("heyy")

        var resultingSamples: [[Float]] = []
        while engine.manualRenderingSampleTime < sourceFile.length {
            do {
                let buffer = AVAudioPCMBuffer(pcmFormat: engine.manualRenderingFormat,
                                              frameCapacity: engine.manualRenderingMaximumFrameCount)!
                let frameCount = sourceFile.length - engine.manualRenderingSampleTime
                let framesToRender = min(AVAudioFrameCount(frameCount), buffer.frameCapacity)

                let status = try engine.renderOffline(framesToRender, to: buffer)

                switch status {
                case .success:
                    // Phew, life is good!
                    break

                case .insufficientDataFromInputNode, .cannotDoInCurrentContext:
                    // The engine couldn't render in the current render call.
                    // Retry in the next iteration.
                    break

                case .error:
                    fatalError("The manual rendering failed.")

                default:
                    fatalError("Something else occurred...?")
                }

                // Next, aggregrate all the stuff \o/
                // TODO(spotlightishere): We're assuming floats, and only obtaining the first frame for this second.
                let bufferValuesPtr = UnsafeMutableBufferPointer<Float>(start: buffer.floatChannelData?.pointee, count: Int(buffer.frameLength))
                let bufferValues = Array(bufferValuesPtr)

                // Let's say we do have a full 48000-length sample.
                // We'll need to split it up into groups of 15.
                // We'll then average all of the values.
                let sampleGroupSize = Int(buffer.frameCapacity) / 15
                let singleSampleValue = bufferValues.chunks(ofCount: sampleGroupSize).map { chunkedValues in
                    abs(vDSP.mean(chunkedValues) * 100)
                }
                resultingSamples.append(singleSampleValue)

            } catch {
                fatalError("The manual rendering failed: \(error).")
            }
        }

        // Stop the player node and engine.
        player.stop()
        engine.stop()

        print(resultingSamples)
        return resultingSamples
    }
}
