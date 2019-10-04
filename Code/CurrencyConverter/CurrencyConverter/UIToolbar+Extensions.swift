//
//  UIToolbar+Extensions.swift
//  CurrencyConverter
//
//  Created by Nicolás Miari on 2019/10/04.
//  Copyright © 2019 Nicolás Miari. All rights reserved.
//

import UIKit

extension UIToolbar {

    /**
     Creates an instance for use as the **input accessory view** of a text-input control such as
     `UITextField` (an input accessory view is displayed _above_ the system keyboard during text input
     to said control).

     The toolbar contains a single, right-aligned button with the specified title, target and action.
     The most comon use-case scenario is a 'close' button to dismiss the keyboard that lacks a dedicated
     key to do so (e.g., numeric pad).

     - parameter title: The title for the noly button in the toolbar.
     - parameter target: An object to which the message defined by `action` will be sent when the only
     button in the toolbar is tapped.
     - parameter action: A selector representing a message to be sent to `target` when the only button in
     the toolbar is tapped.
     */
    convenience init(inputAccessoryWithTitle title: String, target: Any?, action: Selector?) {
        self.init(frame: CGRect(x: 0, y: 0, width: 20, height: 64))
        self.translatesAutoresizingMaskIntoConstraints = false

        let buttonAttributes = [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 15),
            NSAttributedString.Key.foregroundColor: UIColor.systemBlue
        ]

        let dismissButton = UIBarButtonItem(title: title, style: .done, target: target, action: action)
        dismissButton.setTitleTextAttributes(buttonAttributes, for: .normal)
        dismissButton.setTitleTextAttributes(buttonAttributes, for: .highlighted)
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        self.sizeToFit()

        self.barTintColor = UIColor.white
        self.clipsToBounds = true

        self.items = [flexibleSpace, dismissButton]

        layoutIfNeeded()
    }

    override open func didMoveToWindow() {
        super.didMoveToWindow()
        if #available(iOS 11.0, *) {
            if let window = self.window {
                self.bottomAnchor.constraint(lessThanOrEqualToSystemSpacingBelow: window.safeAreaLayoutGuide.bottomAnchor, multiplier: 1.0).isActive = true
            }
        }
    }
}
