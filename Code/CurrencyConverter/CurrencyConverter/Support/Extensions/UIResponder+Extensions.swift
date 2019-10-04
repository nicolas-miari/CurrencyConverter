//
//  UIResponder+Extensions.swift
//  CurrencyConverter
//
//  Created by Nicolás Miari on 2019/10/04.
//  Copyright © 2019 Nicolás Miari. All rights reserved.
//

import UIKit

private var foundFirstResponder: UIResponder? = nil

/**
Taken from: https://stackoverflow.com/a/52823735/433373
*/
extension UIResponder{

    static var first: UIResponder? {

        /*
         Sending an action to 'nil' implicitly sends it to the first responder,
         where we simply capture it for return
         */
        UIApplication.shared.sendAction(#selector(UIResponder.storeFirstResponder(_:)), to: nil, from: nil, for: nil)

        /*
         The following 'defer' statement executes after the return
         While I could use a weak ref and eliminate this, I prefer a hard ref
         which I explicitly clear as it's better for race conditions
         */
        defer {
            foundFirstResponder = nil
        }

        return foundFirstResponder
    }

    @objc func storeFirstResponder(_ sender: AnyObject) {
        foundFirstResponder = self
    }
}
