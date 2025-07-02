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
}
