//
//  ConversionService.swift
//  CurrencyConverter
//
//  Created by Nicolás Miari on 2019/10/04.
//  Copyright © 2019 Nicolás Miari. All rights reserved.
//

import Foundation
/**
 API Documentation: https://currencylayer.com/quickstart
 */

class ConversionService {

    static let shared = ConversionService()

    private var cachedQuotes: [String: Quote] = [:]

    private let networkClient: NetworkClientProtocol

    init(networkClient: NetworkClientProtocol = NetworkClient.shared) {
        self.networkClient = networkClient
        if let cached = try? LocalStore.shared.loadQuotes() {
            self.cachedQuotes = cached
        }
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

        networkClient.get(url: url, params: params, completion: { (result) in
            // TODO: Add support for API errors (scan for 'error' entry)
            guard let json = result as? [String: Any] else {
                return failure(ServiceError.wrongResponseFormat)
            }
            guard let quotesJSON = json["quotes"] as? [String: Any] else {
                return failure(ServiceError.responseCorrupted)
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
        }, failure: {(error) in
            print(error.localizedDescription)
        })
    }
}

// MARK: - Support

enum ServiceError: LocalizedError {
    case quoteUnavailable

    case accessKeyMissing

    case wrongResponseFormat

    case responseCorrupted

    var localizedDescription: String {
        switch self {
        case .quoteUnavailable:
            return "A quote for the requested currency was not present on the server."

        case .accessKeyMissing:
            return "Access Key is missing from Info.plist file."

        case .wrongResponseFormat:
            return "Service response is in the wrong format."

        case .responseCorrupted:
            return "Service response is corrupted."
        }
    }
}
