//
//  DateExtensionsTests.swift
//  CurrencyConverterTests
//
//  Created by Nicolás Miari on 2019/10/07.
//  Copyright © 2019 Nicolás Miari. All rights reserved.
//

import XCTest
@testable import CurrencyConverter

class DateExtensionsTests: XCTestCase {

    func testWithin() {
        let anHourAgo = Date().addingTimeInterval(-3600)
        XCTAssert(anHourAgo.isWithin(3660))
        XCTAssert(anHourAgo.isOlderThan(3559))
    }
}
