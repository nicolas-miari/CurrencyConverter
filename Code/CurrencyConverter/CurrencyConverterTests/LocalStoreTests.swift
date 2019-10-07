//
//  LocalStoreTests.swift
//  CurrencyConverterTests
//
//  Created by Nicolás Miari on 2019/10/07.
//  Copyright © 2019 Nicolás Miari. All rights reserved.
//

import XCTest
@testable import CurrencyConverter

class LocalStoreTests: XCTestCase {

    private lazy var testQuotes: [String: Quote] = {
        let now = Date()
        let testQuotes: [Quote] = [
            Quote(currencies: "USDJPY", rate: 106.0, timeStamp: now),
            Quote(currencies: "USDCAN", rate: 1.01, timeStamp: now),
        ]
        let tuples: [(String, Quote)] = testQuotes.map { (quote) -> (String, Quote) in
            return (quote.currencies, quote)
        }
        let dictionary: [String: Quote] = Dictionary(uniqueKeysWithValues: tuples)
        return dictionary
    }()

    // MARK: - Test Cases
    
    func testStoreAndLoad() throws {
        let payload = testQuotes
        LocalStore.shared.storeQuotes(payload)
        let restored = try LocalStore.shared.loadQuotes()
        XCTAssertEqual(payload, restored)
    }

    func testClear() throws {
        let payload = testQuotes
        LocalStore.shared.storeQuotes(payload)
        LocalStore.shared.clearQuotes()
        let restored = try LocalStore.shared.loadQuotes()
        XCTAssertEqual(restored, [:])
    }

    func testCorruptedData() throws {
        let corruptedArray = ["Corrupted Data"]
        let corruptedData = try JSONEncoder().encode(corruptedArray)
        UserDefaults.standard.set(corruptedData, forKey: "CachedQuotes")

        do {
            _ = try LocalStore.shared.loadQuotes()
        } catch let error as LocalStoreError {
            guard error == .dataCorrupted else {
                XCTFail("Wrong error case: \(error.localizedDescription)")
                return
            }
            _ = error.localizedDescription // (For coverage)
        } catch {
            XCTFail("Wrong error type: \(error.localizedDescription)")
        }
    }
}
