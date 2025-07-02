//
//  ContentView.swift
//  Electricity Price
//
//  Created by Manan Patel on 6/5/25.
//

import SwiftUI

struct ContentView: View {

    @AppStorage("electricityPrice") var electricityPrice: Double?

    var circleColor: Color {
        guard let price = electricityPrice else {
            return .gray
        }
        switch price {
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
                    await PriceFetcher.shared.updatePrice()
                }
            }
            .overlay(
                VStack {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 70))
                        .imageScale(.large)
                        .foregroundStyle(.white)

                    if electricityPrice != nil {
                        Text("\(electricityPrice!.formatted())")
                            .font(.largeTitle)
                            .task {
                                await PriceFetcher.shared.updatePrice()
                            }
                    } else {
                        Text("Loading...")
                            .font(.system(size: 100))
                            .task {
                                await PriceFetcher.shared.updatePrice()
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
