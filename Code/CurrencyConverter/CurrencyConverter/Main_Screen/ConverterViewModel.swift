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

    static let initialInputCurrencyCode: String = "USD"
    static let initialConvertedCurrencyCode: String = "JPY"

    // MARK: - Initialization

    init(bundle: Bundle = .main, currencyFileName: String = "CurrencyCodes") throws {
        // Resource file contents taken from: https://www.currency-iso.org/en/home/tables/table-a1.html
        //
        guard let url = bundle.url(forResource: currencyFileName, withExtension: "csv") else {
            throw ConverterViewModelError.missingResourceFile(name: currencyFileName)
        }

        let csv: String
        do {
            csv = try String(contentsOf: url, encoding: .utf8)
        } catch {
            throw ConverterViewModelError.corruptedResourceFile(detail: error.localizedDescription)
        }

        let rows = csv.components(separatedBy: CharacterSet.newlines)

        self.currencies = rows.compactMap({ (row) -> Currency? in
            let components = row.components(separatedBy: ",")
            guard components.count == 2 else {
                return nil
            }
            return Currency(code: components[0], name: components[1])
        })

        guard let inputIndex = currencies.firstIndex (where: { $0.code == ConverterViewModel.initialInputCurrencyCode }) else {
            let detail = "Resource File Is Corrupted: Missing Initial Input Code '\(ConverterViewModel.initialInputCurrencyCode)'  (\(currencyFileName).csv)"
            throw ConverterViewModelError.corruptedResourceFile(detail: detail)
        }
        self.inputCurrencyIndex =  inputIndex

        guard let convertedIndex = currencies.firstIndex (where: { $0.code == ConverterViewModel.initialConvertedCurrencyCode }) else {
            let detail = "Resource File Is Corrupted: Missing Initial Target Code '\(ConverterViewModel.initialConvertedCurrencyCode)'  (\(currencyFileName).csv)"
            throw ConverterViewModelError.corruptedResourceFile(detail: detail)
        }
        self.convertedCurrencyIndex =  convertedIndex
    }

    // MARK: -
    
    func isValidInputText(_ proposedText: String) -> Bool {
        let dotCount = proposedText.filter{ $0 == "." }.count
        if dotCount > 1 {
            return false
        }
        guard Double(proposedText) != nil else {
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

enum ConverterViewModelError: LocalizedError {
    case missingResourceFile(name: String)
    case corruptedResourceFile(detail: String)

    var localizedDescription: String {
        switch self {
        case .missingResourceFile(let name):
            return "Missing resource file: \(name)"

        case .corruptedResourceFile(let detail):
            return "Corrupted resource file: \(detail)"
        }
    }
}
