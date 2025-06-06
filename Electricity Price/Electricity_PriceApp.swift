//
//  Electricity_PriceApp.swift
//  Electricity Price
//
//  Created by Manan Patel on 6/5/25.
//

import SwiftUI

@main
struct Electricity_PriceApp: App {
    @AppStorage("electricityPrice") var electricityPrice: Double = Double.nan
    init() {
        UserDefaults.standard.register(defaults: [
            "electricityPrice": Double.nan
        ])
        
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .backgroundTask(.appRefresh("ELECTRICITY_PRICE")) {
            await PriceFetcher.shared.updatePrice()
        }
    }
}

class PriceFetcher {
    static let shared = PriceFetcher()
    
    private init() {}

    func updatePrice() async {
        let url = URL(string: "https://hourlypricing.comed.com/api?type=currenthouraverage")!
    
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else {
                print("No data")
                return
            }
            let data_response = try! JSONDecoder().decode([PriceResponse].self, from: data)
            
            let price = Double(data_response[0].price) ?? Double.nan
            UserDefaults.standard.set(price, forKey: "electricityPrice")
        }
        
        task.resume()
    }
}

struct PriceResponse: Decodable {
    let price: String
    let millisUTC: String
}
