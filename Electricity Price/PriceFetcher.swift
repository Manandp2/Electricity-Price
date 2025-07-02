//
//  PriceFetcher.swift
//  Electricity Price
//
//  Created by Manan Patel on 7/1/25.
//

import Foundation
import BackgroundTasks

struct PriceResponse: Decodable {
    let price: String
    let millisUTC: String
}

class PriceFetcher {
    static let shared = PriceFetcher()
    
    private init() {}
    
    static var price: Double? {
        UserDefaults.standard.object(forKey: "electricityPrice") as? Double? ?? nil
    }
    
    static var priceAvailable: Bool {
        PriceFetcher.price != nil
    }
    
    static func fetchPrice() async -> Double {
        let url = URL(string: "https://hourlypricing.comed.com/api?type=currenthouraverage")!
        
        let (data, _ ) = try! await URLSession.shared.data(from: url)
        
        let price_response = try! JSONDecoder().decode([PriceResponse].self, from: data)[0]
        
        let price = Double(price_response.price) ?? Double.nan
        if !price.isNaN {
            UserDefaults.standard.set(price, forKey: "electricityPrice")
        }
        return price
    }

    func updatePrice() async {
        print(">>> Updating electricity price at \(Date())\n")
        let url = URL(string: "https://hourlypricing.comed.com/api?type=currenthouraverage")!

        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                print("No data")
                return
            }
            let data_response = try! JSONDecoder().decode([PriceResponse].self, from: data)

            let price = Double(data_response[0].price) ?? Double.nan
            UserDefaults.standard.set(price, forKey: "electricityPrice")
        }

        task.resume()

        let request = BGAppRefreshTaskRequest(identifier: "ELECTRICITY_PRICE")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 5)  // 5 minutes from now (system may delay)
        do {
            try BGTaskScheduler.shared.submit(request)
            print("Scheduled next refresh for \(Date(timeIntervalSinceNow: 60 * 5))")
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }
}
