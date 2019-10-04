//
//  ConversionService.swift
//  CurrencyConverter
//
//  Created by Nicolás Miari on 2019/10/04.
//  Copyright © 2019 Nicolás Miari. All rights reserved.
//

import Foundation
/**
 Documentation: https://currencylayer.com/quickstart
 */

/// TODO: Move to Info.plist
//let appKey = "dd1930fac78a7adbd6aa99edfaf35a07"

extension Bundle {
    var currencyLayerAccessKey: String? {
        return object(forInfoDictionaryKey: "Currency Layer Access Key") as? String
    }
}

struct Quote: Codable {
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
     The date when the quote was last retrieved from the server, for the purpose of saving
     bandwith (quotes older than 30 minutes are discarded and re-queried). Do not confuse
     with the timestamp that is returned from the server: That indicates how old the quotes
     themselves are, relative to when the market valuation of each currency was last updated.
     */
    let timeStamp: Date
}

class ConversionService {

    static let shared = ConversionService()

    private var cachedQuotes: [String: Quote] = [:]

    init() {
        self.cachedQuotes = LocalStore.shared.loadQuotes()
    }

    let dataLongevityInMinutes = 120

    /**
     Fails if the necessary quote isn't cached.
     */
    private func convert(amount: Double, from srcCurrency: String, to dstCurrency: String) -> Double? {
        let key = "\(srcCurrency)" +  "\(dstCurrency)"
        if let cached = cachedQuotes[key], cached.timeStamp.isWithin(TimeInterval(minutes: dataLongevityInMinutes)) {
            // Use cached value:
            return amount * cached.rate
        }
        let reverseKey = "\(dstCurrency)" +  "\(srcCurrency)"
        if let cached = cachedQuotes[reverseKey], cached.timeStamp.isWithin(TimeInterval(minutes: dataLongevityInMinutes)) {
            // Use cached value (reversed):
            return amount / cached.rate
        }
        return nil
    }

    func convert(amount: Double, from srcCurrency: String, to dstCurrency: String, completion: @escaping ((Double) -> Void), failure: @escaping ((Error) -> Void)) {
        if let cachedResult = convert(amount: amount, from: srcCurrency, to: dstCurrency) {
            return completion(cachedResult)
        }
        // Assume failure means the quotes aren't cached locally yet, and hit the web service:

        let urlString = "http://apilayer.net/api/live"
        let url = URL(string: urlString)!

        guard let accessKey = Bundle.main.currencyLayerAccessKey else {
            return failure(ServiceError.accessKeyMissing)
        }
        let params: [String: Any] = ["access_key": accessKey, "source": srcCurrency, "format": "1"]
        // (skip 'currencies' and retrieve all each time, to save bandwidth.)

        NetworkClient.shared.get(url: url, params: params, completion: { (result) in
            guard let json = result as? [String: Any] else {
                return print("Response is in the wrong format: \(result)")
            }
            guard let quotesJSON = json["quotes"] as? [String: Any] else {
                return print("Response is in the wrong format! (missing all quotes): \(json)")
            }
            /*
             Ignore server timestamp: it only specifies how old the data ON THE SERVER is.
             For our purposes (save bandwidth), we only care how long the data has been sitting on
             the client. Therefore, the timestamp of this freshly retrieved data is NOW:
             */
            let now = Date()

            let quotes = quotesJSON.compactMap { (key, value) -> Quote? in
                guard let rate = value as? Double else {
                    return nil
                }
                return Quote(currencies: key, rate: rate, timeStamp: now)
            }

            // Cache all the quotes:
            quotes.forEach { (quote) in
                self.cachedQuotes[quote.currencies] = quote
            }
            LocalStore.shared.storeQuotes(self.cachedQuotes)

            DispatchQueue.main.async {
                // Now try again, this time using the latest cached quotes:
                guard let cachedResult = self.convert(amount: amount, from: srcCurrency, to: dstCurrency) else {
                    // If it fails AFTER obtaining the latest quotes, it means the quote isn't available on the server either.
                    return failure(ServiceError.quoteUnavailable)
                }
                completion(cachedResult)
            }

            /*
             Sample response:
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
}

enum ServiceError: LocalizedError {
    case quoteUnavailable

    case accessKeyMissing

    var localizedDescription: String {
        switch self {
        case .quoteUnavailable:
            return "A quote for the requested currency was not present on the server."

        case .accessKeyMissing:
            return "Access Key is missing from Info.plist file."
        }
    }
}
