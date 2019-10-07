//
//  ConversionServiceTests.swift
//  CurrencyConverterTests
//
//  Created by Nicolás Miari on 2019/10/07.
//  Copyright © 2019 Nicolás Miari. All rights reserved.
//

import XCTest
@testable import CurrencyConverter

class ConversionServiceTests: XCTestCase {

    private var sampleResponse: [String: Any] {
        return [
            "success": true,
            "timestamp": 1570118947,
            "source": "USD",
            "quotes": [
                "USDUSD":1,
                "USDAUD":1.48179,
                "USDCAD":1.332885,
                "USDPLN":3.94155,
                "USDMXN":19.70502
            ]
        ]
    }

    // MARK: - Test Cases

    func testSuccessfulConversion() {
        LocalStore.shared.clearQuotes()
        let client = MockNetworkClient(result: sampleResponse)
        let service = ConversionService(networkClient: client)

        let convertExpectation = expectation(description: "Convert")

        service.convert(amount: 100, from: "USD", to: "AUD", completion: { (convertedAmount) in
            convertExpectation.fulfill()
        }, failure: {(error) in
            XCTFail("Error: \(error.localizedDescription)")
        })
        wait(for: [convertExpectation], timeout: 1)
    }

    func testSuccessfulReverseConversion() {
        LocalStore.shared.clearQuotes()
        let client = MockNetworkClient(result: sampleResponse)
        let service = ConversionService(networkClient: client)

        let convertExpectation = expectation(description: "ReverseConvert")

        service.convert(amount: 100, from: "AUD", to: "USD", completion: { (convertedAmount) in
            convertExpectation.fulfill()
        }, failure: {(error) in
            XCTFail("Error: \(error.localizedDescription)")
        })
        wait(for: [convertExpectation], timeout: 1)
    }

    func testQuoteUnavailable() {
        LocalStore.shared.clearQuotes()
        let client = MockNetworkClient(result: sampleResponse)
        let service = ConversionService(networkClient: client)

        let failExpectation = expectation(description: "Convert Fail")

        service.convert(amount: 100, from: "USD", to: "JPY", completion: { (convertedAmount) in
            XCTFail("Unexpected success.")
        }, failure: {(error) in
            guard let serviceError = error as? ServiceError, serviceError == .quoteUnavailable else {
                return XCTFail("Wrong error: \(error.localizedDescription)")
            }
            failExpectation.fulfill()
        })

        wait(for: [failExpectation], timeout: 1)
    }
}
