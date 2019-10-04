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

    var inputCurrencyIndex: Int

    var convertedCurrencyIndex: Int

    var inputCurrency: Currency {
        return currencies[inputCurrencyIndex]
    }

    var convertedCurrency: Currency {
        return currencies[convertedCurrencyIndex]
    }

    // MARK: - Initialization

    init() {
        // Resource file contents taken from: https://www.currency-iso.org/en/home/tables/table-a1.html
        //
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

        guard let inputIndex = currencies.firstIndex (where: { $0.code == "USD" }) else {
            fatalError("Resource File Is Corrupted: Missing US Dollar (CurrencyCodes.csv)")
        }
        self.inputCurrencyIndex =  inputIndex

        guard let convertedIndex = currencies.firstIndex (where: { $0.code == "JPY" }) else {
            fatalError("Resource File Is Corrupted: Missing Japanese Yen (CurrencyCodes.csv)")
        }
        self.convertedCurrencyIndex =  convertedIndex
    }

    // MARK: -
    
    func isValidInputText(_ proposedText: String) -> Bool {
        let dotCount = proposedText.filter{ $0 == "." }.count
        if dotCount > 1 {
            return false
        }
        return true
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
}
