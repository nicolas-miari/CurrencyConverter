//
//  TimeIntervalExtensionsTests.swift
//  CurrencyConverterTests
//
//  Created by Nicolás Miari on 2019/10/07.
//  Copyright © 2019 Nicolás Miari. All rights reserved.
//

import XCTest
@testable import CurrencyConverter

class TimeIntervalExtensionsTests: XCTestCase {

    func testMinutes() {

        let instance = TimeInterval(minutes: 60)
        let reference = TimeInterval(3600)

        XCTAssertEqual(instance, reference)
    }

}
