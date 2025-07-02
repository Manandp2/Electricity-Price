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
    var price: String
}

struct Provider: TimelineProvider {

    typealias Entry = PriceEntry

    func placeholder(in context: Context) -> Entry {
        Entry(date: Date(), price: "place holder (Should never be rendered)")
    }

    func getSnapshot(in context: Context, completion: @escaping (Entry) -> Void) {
        var price: String
        if context.isPreview && !PriceFetcher.priceAvailable {
            price = "price"
        } else {
            price = String(PriceFetcher.price)
        }
        let entry = Entry(date: Date(), price: price)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        Task {
            let currentDate = Date()

            let price = await PriceFetcher.fetchPrice()
            let entry = PriceEntry(date: currentDate, price: String(price))

            let timeline = Timeline(
                entries: [entry],
                policy: .after(Calendar.current.date(byAdding: DateComponents(second: 300), to: currentDate)!)
            )
            completion(timeline)
        }
    }
}

struct Price_WidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            Text("Last Updated:")
            Text(entry.date, style: .time)

            Text("Price:")
            Text(entry.price)
        }
    }
}

struct Price_Widget: Widget {
    let kind: String = "Price_Widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                switch Double(entry.price) ?? Double.nan {
                case ..<5:
                    Price_WidgetEntryView(entry: entry)
                        .containerBackground(.green, for: .widget)
                case 5..<10:
                    Price_WidgetEntryView(entry: entry)
                        .containerBackground(.orange, for: .widget)
                default:
                    Price_WidgetEntryView(entry: entry)
                        .containerBackground(.red, for: .widget)
                }
            } else {
                Price_WidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Price Widget")
        .description("This widget will show the current electricity price.")
    }
}

#Preview(as: .systemSmall) {
    Price_Widget()
} timeline: {
    PriceEntry(date: .now, price: "10")
    PriceEntry(date: .now, price: "5")
}
