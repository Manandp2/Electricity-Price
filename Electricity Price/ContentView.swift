//
//  ContentView.swift
//  Electricity Price
//
//  Created by Manan Patel on 6/5/25.
//

import SwiftUI

struct ContentView: View {

    @AppStorage("electricityPrice") var electricityPrice = Double.nan

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
            .onTapGesture {
                Task {
                    await PriceFetcher.fetchPrice()
                }
            }
            .overlay(
                VStack {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 70))
                        .imageScale(.large)
                        .foregroundStyle(.white)

                    if !electricityPrice.isNaN {
                        Text("\(electricityPrice.formatted())")
                            .font(.largeTitle)
                            .task {
                                await _ = PriceFetcher.fetchPrice()
                            }
                    } else {
                        Text("Loading...")
                            .font(.system(size: 100))
                            .task {
                                await _ = PriceFetcher.fetchPrice()
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
