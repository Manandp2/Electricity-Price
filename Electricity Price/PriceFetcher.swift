//
//  PriceFetcher.swift
//  Electricity Price
//
//  Created by Manan Patel on 7/1/25.
//

import Foundation

let sharedDefaults = UserDefaults(suiteName: "group.mananpatel.ElectricityPrice") ?? .standard

struct PriceResponse: Decodable {
    let price: String
    let millisUTC: String
}

enum PriceFetcher {

    static var price: Double {
        // UserDefaults returns 0.0 for missing keys, so we check for existence first
        guard sharedDefaults.object(forKey: "electricityPrice") != nil else {
            return Double.nan
        }
        return sharedDefaults.double(forKey: "electricityPrice")
    }

    static var lastUpdated: Date? {
        guard sharedDefaults.object(forKey: "electricityPriceLastUpdated") != nil else {
            return nil
        }
        let interval = sharedDefaults.double(forKey: "electricityPriceLastUpdated")
        return Date(timeIntervalSinceReferenceDate: interval)
    }

    static var priceAvailable: Bool {
        !price.isNaN
    }

    @discardableResult
    static func fetchPrice() async -> Double {
        let url = URL(string: "https://hourlypricing.comed.com/api?type=currenthouraverage")!
        guard let (data, _) = try? await URLSession.shared.data(from: url),
              let response = try? JSONDecoder().decode([PriceResponse].self, from: data).first,
              let price = Double(response.price) else {
            return Double.nan
        }
        sharedDefaults.set(price, forKey: "electricityPrice")
        sharedDefaults.set(Date().timeIntervalSinceReferenceDate, forKey: "electricityPriceLastUpdated")
        return price
    }
}
