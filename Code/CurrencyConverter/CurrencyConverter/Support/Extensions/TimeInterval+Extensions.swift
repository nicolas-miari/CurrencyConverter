//
//  TimeInterval+Extensions.swift
//  CurrencyConverter
//
//  Created by Nicolás Miari on 2019/10/04.
//  Copyright © 2019 Nicolás Miari. All rights reserved.
//

import Foundation

extension TimeInterval {
    init(minutes: Int) {
        let seconds = minutes * 60
        self = TimeInterval(seconds)
    }
}
