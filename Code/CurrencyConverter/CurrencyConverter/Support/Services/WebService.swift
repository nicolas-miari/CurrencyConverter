//
//  WebService.swift
//  CurrencyConverter
//
//  Created by Nicolás Miari on 2019/10/04.
//  Copyright © 2019 Nicolás Miari. All rights reserved.
//

import Foundation
/**
 Documentation: https://currencylayer.com/quickstart
 */

let appKey = "dd1930fac78a7adbd6aa99edfaf35a07"


struct RateResult {
    let srcCurrencyIdentifier: String
    let dstCurrencyIdentifier: String
    let rate: Double
    let timeStamp: Date
}

struct Quote {
    /**
     Concatenated in order, following the format returned by the server. So, when the rate is for
     converting from USD to CAN, this property has the value "USDCAN".
     */
    let currencies: String

    /**
     The conversion rate. If currencies is `USDCAN`, then 1 USD must equal `rate` times 1 CAN.
     */
    let rate: Double

    /**
     */
    let timeStamp: Date
}

class ConversionService {

    static let shared = ConversionService()
    
    var cachedRates: [String: RateResult] = [:]

    var cachedQuotes: [String: Quote] = [:]

    func convert(amount: Double, from srcCurrency: String, to dstCurrency: String, completion: @escaping ((Double) -> Void)) {

        let key = self.key(forCurrencies: srcCurrency, and: dstCurrency)
        if let cached = cachedQuotes[key], cached.timeStamp.isWithin(TimeInterval(minutes: 30)) {
            // Use cached value:
            return completion(amount * cached.rate)
        }
        let reverseKey = self.key(forCurrencies: dstCurrency, and: srcCurrency)
        if let cached = cachedQuotes[reverseKey], cached.timeStamp.isWithin(TimeInterval(minutes: 30)) {
            // Use cached value (reversed):
            return completion(amount / cached.rate)
        }

        let urlString = "https://apilayer.net/api/live"
        let url = URL(string: urlString)!

        let params: [String: Any] = [
            "access_key": appKey,
            "source": srcCurrency,
            //"currencies": dstCurrency,
            "format": "1"
        ]
        NetworkClient.shared.get(url: url, params: params, completion: { (result) in
            guard let json = result as? [String: Any] else {
                return print("Response is in the wrong format!")
            }
            guard let quotesJSON = json["quotes"] as? [String: Any] else {
                return print("Response is in the wrong format! (missing quotes)")
            }
            guard let timeStamp = json["timestamp"] as? Int else {
                return print("Response is in the wrong format! (missing timestamp)")
            }
            let timeStampDate = Date(timeIntervalSince1970: TimeInterval(timeStamp))

            let quotes = quotesJSON.compactMap { (key, value) -> Quote? in
                guard let rate = value as? Double else {
                    return nil
                }
                return Quote(currencies: key, rate: rate, timeStamp: timeStampDate)
            }

            // Cache them:
            quotes.forEach { (quote) in
                self.cachedQuotes[quote.currencies] = quote
            }


            /*
             {
               "success":true,
               "terms":"https:\/\/currencylayer.com\/terms",
               "privacy":"https:\/\/currencylayer.com\/privacy",
               "timestamp":1570118947,
               "source":"USD",
               "quotes":{
                 "USDUSD":1,
                 "USDAUD":1.48179,
                 "USDCAD":1.332885,
                 "USDPLN":3.94155,
                 "USDMXN":19.70502
               }
             }
             */

        }, failure: {(error) in
            print(error.localizedDescription)
        })
    }

    private func key(forCurrencies first: String, and second: String) -> String {
        let sorted = [first, second].sorted()
        return sorted.joined(separator: "")
    }
}

extension TimeInterval {
    init(minutes: Int) {
        let seconds = minutes * 60
        self = TimeInterval(seconds)
    }
}

extension Date {
    func isOlderThan(_ timeInterval: TimeInterval) -> Bool {
        let now = Date()
        let elapsed = now.timeIntervalSince(self)
        return (elapsed > timeInterval)
    }

    func isWithin(_ timeInterval: TimeInterval) -> Bool {
        let now = Date()
        let elapsed = now.timeIntervalSince(self)
        return (elapsed <= timeInterval)
    }
}
