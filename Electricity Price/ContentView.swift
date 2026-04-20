//
//  ContentView.swift
//  Electricity Price
//
//  Created by Manan Patel on 6/5/25.
//

import SwiftUI

struct ContentView: View {

    @AppStorage("electricityPrice", store: sharedDefaults) var electricityPrice = Double.nan
    @AppStorage("electricityPriceLastUpdated", store: sharedDefaults) private var lastUpdatedInterval: Double = 0

    private var lastUpdated: Date? {
        lastUpdatedInterval > 0 ? Date(timeIntervalSinceReferenceDate: lastUpdatedInterval) : nil
    }

    var circleColor: Color {
        switch electricityPrice {
        case .nan:
            return .gray
        case ..<5:
            return .green
        case 5..<10:
            return .orange
        default:
            return .red
        }
    }

    var body: some View {
        Circle()
            .fill(circleColor)
            .padding()
            .task {
                await PriceFetcher.fetchPrice()
            }
            .onTapGesture {
                Task {
                    await PriceFetcher.fetchPrice()
                }
            }
            .overlay(
                VStack(spacing: 8) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 70))
                        .foregroundStyle(.white)

                    if electricityPrice.isNaN {
                        ProgressView()
                            .tint(.white)
                            .scaleEffect(1.5)
                    } else {
                        Text("\(electricityPrice.formatted())¢/kWh")
                            .font(.largeTitle)
                            .bold()
                            .foregroundStyle(.white)

                        if let lastUpdated {
                            Text("Updated \(lastUpdated, style: .relative) ago")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.8))
                        }
                    }
                }
                .padding()
            )
    }

}

#Preview {
    ContentView()
}
