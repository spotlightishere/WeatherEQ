//
//  WeatherView.swift
//  WeatherEQ
//
//  Created by Spotlight Deveaux on 2025-01-08.
//

import Charts
import SwiftUI

struct WeatherEQChart: View {
    var entries: [Double]

    // Vaguely sampled. We start off wth a white color.
    let startingBarColor = Color(red: 0.78, green: 0.95, blue: 0.99)
    // We end with a light blue.
    // (Note that we do the opposite for rain.)
    let endingBarColor = Color(red: 0.63, green: 0.86, blue: 0.98)

    var body: some View {
        Chart {
            ForEach(Array(entries.enumerated()), id: \.offset) { index, current in
                BarMark(
                    x: .value("Frequency Range", index),
                    y: .value("Intensity", current),
                    width: 5
                )
                // Match to SwiftUI coloring
                .foregroundStyle(
                    .linearGradient(
                        colors: [startingBarColor, endingBarColor],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .cornerRadius(5.0)
            }
        }
        // We will always go from 0 to 1.0.
        .chartYScale(domain: [0, 1.0])
        // Set up some things to mirror Apple.
        .chartYAxis {
            // Our 0.0 axis line must be a solid line.
            AxisMarks(values: [0.0]) {
                AxisGridLine()
            }

            // Beyond that, we have three dotted lines.
            // These are each 1/3rd, so we'll approximate.
            AxisMarks(values: [0.33, 0.66, 1.0]) {
                AxisGridLine(stroke: .init(lineWidth: 1, dash: [2]))
            }
        }
        // No automatic X-axis lines, please.
        // They do not allow us to position as we desire.
        .chartXAxis {}
        .chartXAxisLabel(position: .bottom, alignment: .leading, spacing: 0.0) {
            Text("Now")
                .bold()
        }
        .chartXAxisLabel(position: .bottom, alignment: .trailing, spacing: 0.0) {
            Text("60m")
                .bold()
        }
    }
}

struct WeatherView: View {
    // The official Weather app has 15 bars,
    // representing 4 minute increments over 60 minutes.
    //
    // For our purposes, we'll have 15 samples
    // of EQ over the audible range.
    // This will scale from 0 to 100, maybe?
    // TODO(spotlightishere): Fix up
    var eqEntries: [Double]

    var body: some View {
        ViewThatFits {
            // This seems to vaguely be  what Apple does.
            VStack {
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        HStack {
                            // City name and location symbol
                            HStack(spacing: 3) {
                                Text("Dallas")
                                    .font(.system(size: 14.0))
                                    .bold()

                                Image(systemName: "location.fill")
                                    .resizable()
                                    .frame(width: 10, height: 10)
                            }

                            Spacer()
                            Image(systemName: "snowflake")
                                .resizable()
                                .frame(width: 12, height: 12)
                        }
                        .padding(.bottom, 2.0)

                        // The line break here implies other things
                        // may be going on, but meh.
                        Text("Snow for the\nnext hour")
                            .fontWeight(.medium)
                            .shadow(color: .black, radius: 25.0)
                            .font(.system(size: 13.0))

                        WeatherEQChart(entries: eqEntries)
                    }
                }
            }.padding(10)
                .compositingGroup()
                .shadow(radius: 5)
                // TODO(spotlightishere): This may be odd...
                .frame(width: 150, height: 150)
        }
    }
}

#Preview {
    let mockEqEntries = [
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

    VStack {
        WeatherView(eqEntries: mockEqEntries)
            // Some padding appears to be added by the system.
            .padding(2)
            .background(Color(red: 0.36, green: 0.44, blue: 0.54).gradient)
            .cornerRadius(24)
    }.frame(width: 500, height: 500)
        .environment(\.colorScheme, .dark)
}
