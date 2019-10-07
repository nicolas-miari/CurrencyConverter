//
//  ConverterViewModelTests.swift
//  CurrencyConverterTests
//
//  Created by Nicolás Miari on 2019/10/07.
//  Copyright © 2019 Nicolás Miari. All rights reserved.
//

import XCTest
@testable import CurrencyConverter

class ConverterViewModelTests: XCTestCase {

    private func initializeMissingCurrency(_ code: String) {
        let fileName = "CurrencyCodesMissing" + code
        let bundle = Bundle(for: type(of: self))

        do {
            _ = try ConverterViewModel(bundle: bundle, currencyFileName: fileName)
            XCTFail("Unexpected Success")
        } catch let error as ConverterViewModelError {
            switch error {
            case .corruptedResourceFile(_):
                _ = error.localizedDescription // (for coverage)
            default:
                XCTFail("Wrong error case: \(error.localizedDescription)")
            }
        } catch {
            XCTFail("Wrong error type: \(error.localizedDescription)")
        }
    }

    // MARK: - Test Cases

    func testInitWithMissingResource () {
        let bundle = Bundle(for: type(of: self))

        do {
            _ = try ConverterViewModel(bundle: bundle, currencyFileName: "Nonexistant")
            XCTFail("Unexpected Success")
        } catch let error as ConverterViewModelError {
            switch error {
            case .missingResourceFile(_):
                _ = error.localizedDescription // (for code coverage)

            default:
                XCTFail("Wrong error case: \(error.localizedDescription)")
            }
        } catch {
            XCTFail("Wrong error type: \(error.localizedDescription)")
        }
    }

    func testInitWrongEncoding() {
        let bundle = Bundle(for: type(of: self))
        do {
            _ = try ConverterViewModel(bundle: bundle, currencyFileName: "CurrencyCodesWrong")
            XCTFail("Unexpected Success")
        } catch let error as ConverterViewModelError {
            switch error {
            case .corruptedResourceFile(_):
                _ = error.localizedDescription // (for code coverage)

            default:
                XCTFail("Wrong error case: \(error.localizedDescription)")
            }
        } catch {
            XCTFail("Wrong error type: \(error.localizedDescription)")
        }
    }

    func testInitMissingKeyCurrencies() {
        initializeMissingCurrency("USD")
        initializeMissingCurrency("JPY")
    }

    func testValidInput() throws {
        let viewModel = try ConverterViewModel()

        XCTAssertTrue(viewModel.isValidInputText("0.00001"))
        XCTAssertTrue(viewModel.isValidInputText("123456."))
        XCTAssertTrue(viewModel.isValidInputText("123"))
        XCTAssertTrue(viewModel.isValidInputText("5505.5"))
        XCTAssertTrue(viewModel.isValidInputText("234.002"))
        XCTAssertTrue(viewModel.isValidInputText("0."))
    }

    func testInvalidInput() throws {
        let viewModel = try ConverterViewModel()

        XCTAssertFalse(viewModel.isValidInputText(""))
        XCTAssertFalse(viewModel.isValidInputText(" "))
        XCTAssertFalse(viewModel.isValidInputText("."))
        XCTAssertFalse(viewModel.isValidInputText(".."))
        XCTAssertFalse(viewModel.isValidInputText(".0."))
        XCTAssertFalse(viewModel.isValidInputText("0.."))
        XCTAssertFalse(viewModel.isValidInputText("..0"))
        XCTAssertFalse(viewModel.isValidInputText("...1"))
        XCTAssertFalse(viewModel.isValidInputText("abc"))
    }

    func testRowAccess() throws {
        let viewModel = try ConverterViewModel()
        let row = 6

        let currency = viewModel.currency(at: row)
        XCTAssertEqual(row, viewModel.row(for: currency))
    }
}
