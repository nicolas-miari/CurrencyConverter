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

    // MARK: - XCTestCase

    override class func setUp() {
        LocalStore.shared.clearQuotes()
    }

    override func tearDown() {
        LocalStore.shared.clearQuotes()
    }

    // MARK: -

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

    private var responseWithInvalidQuote: [String: Any] {
        return [
            "success": true,
            "timestamp": 1570118947,
            "source": "USD",
            "quotes": [
                "USDUSD":1,
                "USDAUD":1.48179,
                "USDCAD":"HAHAHAHA",
                "USDPLN":3.94155,
                "USDMXN":19.70502
            ]
        ]
    }

    private var responseMissingQuotes: [String: Any] {
        return [
            "Hahahahaha": "Yeah"
        ]
    }

    // MARK: - Test Cases

    func testSuccessfulConversion() {
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

    func testWrongResponseFormat() {
        let client = MockNetworkClient(result: "AAAA")
        let service = ConversionService(networkClient: client)

        let failExpectation = expectation(description: "Convert Fail Wrong Format")

        service.convert(amount: 100, from: "USD", to: "AUD", completion: { (convertedAmount) in
            XCTFail("Unexpected success.")
        }, failure: {(error) in
            guard let serviceError = error as? ServiceError, serviceError == .wrongResponseFormat else {
                return XCTFail("Wrong error: \(error.localizedDescription)")
            }
            _ = serviceError.localizedDescription // (for code cofverage)
            failExpectation.fulfill()
        })

        wait(for: [failExpectation], timeout: 1)
    }

    func testResponseMissingAllQuotes() {
        let client = MockNetworkClient(result: responseMissingQuotes)
        let service = ConversionService(networkClient: client)

        let failExpectation = expectation(description: "Convert Fail Wrong Format")

        service.convert(amount: 100, from: "USD", to: "AUD", completion: { (convertedAmount) in
            XCTFail("Unexpected success.")
        }, failure: {(error) in
            guard let serviceError = error as? ServiceError, serviceError == .responseCorrupted else {
                return XCTFail("Wrong error: \(error.localizedDescription)")
            }
            _ = serviceError.localizedDescription // (for code cofverage)
            failExpectation.fulfill()
        })

        wait(for: [failExpectation], timeout: 1)
    }

    func testResponseWithInvalidQuotes() {
        let client = MockNetworkClient(result: responseWithInvalidQuote)
        let service = ConversionService(networkClient: client)

        let successExpectation = expectation(description: "Convert Ignoring Wrong Quotes")

        service.convert(amount: 100, from: "USD", to: "AUD", completion: { (convertedAmount) in
            successExpectation.fulfill()
        }, failure: {(error) in
            XCTFail(error.localizedDescription)
        })

        wait(for: [successExpectation], timeout: 1)
    }


    func testQuoteUnavailable() {
        let client = MockNetworkClient(result: sampleResponse)
        let service = ConversionService(networkClient: client)

        let failExpectation = expectation(description: "Convert Fail")

        service.convert(amount: 100, from: "USD", to: "JPY", completion: { (convertedAmount) in
            XCTFail("Unexpected success.")
        }, failure: {(error) in
            guard let serviceError = error as? ServiceError, serviceError == .quoteUnavailable else {
                return XCTFail("Wrong error: \(error.localizedDescription)")
            }
            _ = serviceError.localizedDescription // (for code cofverage)
            failExpectation.fulfill()
        })

        wait(for: [failExpectation], timeout: 1)
    }

    func testCachedQuotes() {
        let quote = Quote(currencies: "USDJPY", rate: 106.3, timeStamp: Date())
        LocalStore.shared.storeQuotes([quote.currencies: quote])

        let client = MockNetworkClient(result: sampleResponse)
        let service = ConversionService(networkClient: client)

        let successExpectation = expectation(description: "Convert Using Cached Quotes")

        service.convert(amount: 10, from: "USD", to: "JPY", completion: { (convertedAmount) in
            successExpectation.fulfill()

        }, failure: { (_) in
            XCTFail()
        })
        wait(for: [successExpectation], timeout: 1)
    }
}
