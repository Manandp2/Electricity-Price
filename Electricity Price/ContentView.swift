//
//  ContentView.swift
//  Electricity Price
//
//  Created by Manan Patel on 6/5/25.
//

import SwiftUI

struct ContentView: View {
    
    @AppStorage("electricityPrice") var electricityPrice: Double = Double.nan
    
    var body: some View {
        VStack {
            Image(systemName: "bolt.fill")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("\(electricityPrice.isNaN ? "Fetching Price" : electricityPrice.formatted() + " cents")")
                .task {
                    await PriceFetcher.shared.updatePrice()
                }
        }
        .padding()
    }
    
}

#Preview {
    ContentView()
}
