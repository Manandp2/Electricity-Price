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
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background {
                scheduleBackgroundRefresh()
            }
        }
        .backgroundTask(.appRefresh("ELECTRICITY_PRICE")) {
            await PriceFetcher.fetchPrice()
            // Re-schedule so the system knows to wake the app again later
            scheduleBackgroundRefresh()
        }
    }

    private nonisolated func scheduleBackgroundRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "ELECTRICITY_PRICE")
        // Ask the system to wake the app no sooner than 15 minutes from now
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)
        try? BGTaskScheduler.shared.submit(request)
    }
}
