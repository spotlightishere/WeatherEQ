//
//  WeatherEQWidget.swift
//  WeatherEQ Widget
//
//  Created by Spotlight Deveaux on 2025-01-08.
//

import SwiftUI
import WidgetKit

struct Provider: TimelineProvider {
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
        for hourOffset in 0 ..< 100 {
            let entryDate = Calendar.current.date(byAdding: .second, value: hourOffset, to: currentDate)!
            // Populate with dummy data
            let eqEntries = (0 ..< 15).map { _ in Double.random(in: 0 ... 1) }
            let entry = SimpleEntry(date: entryDate, eqEntries: eqEntries)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let eqEntries: [Double]

    static let mock = [
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
