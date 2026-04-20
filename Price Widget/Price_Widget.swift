//
//  Price_Widget.swift
//  Price Widget
//
//  Created by Manan Patel on 6/8/25.
//

import SwiftUI
import WidgetKit

struct PriceEntry: TimelineEntry {
    var date: Date
    var price: Double
}

struct Provider: TimelineProvider {

    typealias Entry = PriceEntry

    func placeholder(in context: Context) -> Entry {
        Entry(date: Date(), price: Double.nan)
    }

    func getSnapshot(in context: Context, completion: @escaping (Entry) -> Void) {
        // Show a sample price in preview mode when no real price is available
        let price = context.isPreview && !PriceFetcher.priceAvailable ? 4.5 : PriceFetcher.price
        completion(Entry(date: Date(), price: price))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        Task {
            let currentDate = Date()
            let price = await PriceFetcher.fetchPrice()
            let entry = PriceEntry(date: currentDate, price: price)
            let nextUpdate = Calendar.current.date(byAdding: .minute, value: 5, to: currentDate)!
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            completion(timeline)
        }
    }
}

struct Price_WidgetEntryView: View {
    var entry: Provider.Entry

    private var formattedPrice: String {
        entry.price.isNaN ? "—" : "\(entry.price.formatted())¢/kWh"
    }

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: "bolt.fill")
                .font(.title2)
            Text(formattedPrice)
                .font(.headline)
                .bold()
            Text(entry.price.isNaN ? "Loading..." : "at \(entry.date, style: .time)")
                .font(.caption2)
                .opacity(0.8)
        }
        .foregroundStyle(.white)
    }
}

struct Price_Widget: Widget {
    let kind: String = "Price_Widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            // Determine background color based on price; gray means no data yet
            let bgColor: Color = entry.price.isNaN ? .gray
                : entry.price < 5 ? .green
                : entry.price < 10 ? .orange
                : .red

            Price_WidgetEntryView(entry: entry)
                .containerBackground(bgColor, for: .widget)
        }
        .configurationDisplayName("Electricity Price")
        .description("Shows the current hourly electricity price.")
    }
}

#Preview(as: .systemSmall) {
    Price_Widget()
} timeline: {
    PriceEntry(date: .now, price: 4.5)
    PriceEntry(date: .now, price: 7.2)
    PriceEntry(date: .now, price: 12.0)
    PriceEntry(date: .now, price: Double.nan)
}
