//
//  Quote.swift
//  CurrencyConverter
//
//  Created by Nicolás Miari on 2019/10/07.
//  Copyright © 2019 Nicolás Miari. All rights reserved.
//

import Foundation

struct Quote: Codable, Equatable {
    /**
     Concatenated in order, following the format returned by the server. So, when the rate is for
     converting from USD to CAN, this property has the value "USDCAN".
     */
    let currencies: String

    /**
     The conversion rate. If currencies is `USDCAN`, then 1 USD must equal `rate` times 1 CAN.
     */
    let rate: Double

    /**
     The date when the quote was last retrieved from the server, for the purpose of saving
     bandwith (quotes older than 30 minutes are discarded and re-queried). Do not confuse
     with the timestamp that is returned from the server: That indicates how old the quotes
     themselves are, relative to when the market valuation of each currency was last updated.
     */
    let timeStamp: Date
}
