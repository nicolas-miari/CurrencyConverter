//
//  Date+Extensions.swift
//  CurrencyConverter
//
//  Created by Nicolás Miari on 2019/10/04.
//  Copyright © 2019 Nicolás Miari. All rights reserved.
//

import Foundation

extension Date {
    func isOlderThan(_ timeInterval: TimeInterval) -> Bool {
        let now = Date()
        let elapsed = now.timeIntervalSince(self)
        return (elapsed > timeInterval)
    }

    func isWithin(_ timeInterval: TimeInterval) -> Bool {
        let now = Date()
        let elapsed = now.timeIntervalSince(self)
        return (elapsed <= timeInterval)
    }
}
