//
//  WeatherEQWidget.swift
//  WeatherEQ Widget
//
//  Created by Spotlight Deveaux on 2025-01-08.
//

import SwiftUI
import WidgetKit

struct Provider: TimelineProvider {
    // Initialize with dummy data.
    // You'd want to replace this with your actual song.
    let fullEqData: [[Float]] = (0 ..< 100).map { _ in
        (0 ..< 15).map { _ in Float.random(in: 0 ... 1) }
    }

    func placeholder(in _: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), eqEntries: SimpleEntry.mock)
    }

    func getSnapshot(in _: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(date: Date(), eqEntries: SimpleEntry.mock)
        completion(entry)
    }

    func getTimeline(in _: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for index in 0 ..< fullEqData.count {
            let entryDate = Calendar.current.date(byAdding: .second, value: index, to: currentDate)!
            // Populate with dummy data
            let eqEntries = fullEqData[index]
            let entry = SimpleEntry(date: entryDate, eqEntries: eqEntries)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let eqEntries: [Float]

    static let mock: [Float] = [
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
    ]
}

struct WeatherEQ_WidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        WeatherView(eqEntries: entry.eqEntries)
    }
}

struct WeatherEQ_Widget: Widget {
    let kind: String = "WeatherEQ_Widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WeatherEQ_WidgetEntryView(entry: entry)
                .containerBackground(Color(red: 0.36, green: 0.44, blue: 0.54).gradient, for: .widget)
        }
        .configurationDisplayName("WeatherEQ")
        .description("Weather with an audible twist.")
    }
}
