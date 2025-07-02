//
//  Electricity_PriceApp.swift
//  Electricity Price
//
//  Created by Manan Patel on 6/5/25.
//

import BackgroundTasks
import SwiftUI

@main
struct Electricity_PriceApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .backgroundTask(.appRefresh("ELECTRICITY_PRICE")) {
            await _ = PriceFetcher.fetchPrice()
        }
    }
}

