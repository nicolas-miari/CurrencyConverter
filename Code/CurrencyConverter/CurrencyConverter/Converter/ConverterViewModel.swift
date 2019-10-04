//
//  ConverterViewModel.swift
//  CurrencyConverter
//
//  Created by Nicolás Miari on 2019/10/04.
//  Copyright © 2019 Nicolás Miari. All rights reserved.
//

import Foundation

struct Currency {
    let code: String
    let name: String
}

class ConverterViewModel {

    let currencies: [Currency]

    init() {
        /*
         Read resource file (contents taken from: https://www.currency-iso.org/en/home/tables/table-a1.html)
         */
        guard let url = Bundle.main.url(forResource: "CurrencyCodes", withExtension: "csv") else {
            fatalError("Missing Resource File: CurrencyCodes.csv")
        }
        guard let csv = try? String(contentsOf: url, encoding: .utf8) else {
            fatalError("Resource File Is Corrupted: CurrencyCodes.csv")
        }
        let rows = csv.components(separatedBy: CharacterSet.newlines)

        self.currencies = rows.compactMap({ (row) -> Currency? in
            let components = row.components(separatedBy: ",")
            guard components.count == 2 else {
                return nil
            }
            return Currency(code: components[0], name: components[1])
        })
    }

    var numberOfCurrencies: Int {
        return currencies.count
    }

    func currency(at index: Int) -> Currency {
        return currencies[index]
    }

    func row(for currency: Currency) -> Int? {
        return currencies.firstIndex { $0.code == currency.code }
    }

    var indexOfDefaultSourceCurrency: Int {
        return currencies.firstIndex { $0.code == "USD" } ?? 0
    }

    var indexOfDefaultDestinationCurrency: Int {
        return currencies.firstIndex { $0.code == "JPY" } ?? 1
    }
}
