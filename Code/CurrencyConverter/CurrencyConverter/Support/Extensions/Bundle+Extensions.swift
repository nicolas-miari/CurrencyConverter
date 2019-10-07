//
//  Bundle+Extensions.swift
//  CurrencyConverter
//
//  Created by Nicolás Miari on 2019/10/07.
//  Copyright © 2019 Nicolás Miari. All rights reserved.
//

import Foundation

extension Bundle {
    var currencyLayerAccessKey: String? {
        return object(forInfoDictionaryKey: "Currency Layer Access Key") as? String
    }
}
