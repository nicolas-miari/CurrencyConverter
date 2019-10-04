//
//  LocalStore.swift
//  CurrencyConverter
//
//  Created by Nicolás Miari on 2019/10/04.
//  Copyright © 2019 Nicolás Miari. All rights reserved.
//

import Foundation

/**
 The actual implementation uses NSUserDefaults for now; but because it's an implementation
 detail abstracted into this class, swapping it by a more robust solution shouldn' affect
 the rest of the code as long as the interface for this class remains intact.
 */
class LocalStore {

    static let shared = LocalStore()

    func storeQuotes(_ quotes: [String: Quote]) {
        let data = try? JSONEncoder().encode(quotes)
        UserDefaults.standard.set(data, forKey: "CachedQuotes")
    }

    func loadQuotes() -> [String: Quote] {
        guard let data = UserDefaults.standard.data(forKey: "CachedQuotes") else {
            return [:]
        }
        guard let dictionary = try? JSONDecoder().decode([String: Quote].self, from: data) else {
            return [:]
        }
        print(dictionary.keys)
        
        return dictionary
    }
}
