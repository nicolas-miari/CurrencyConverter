//
//  InputButton.swift
//  CurrencyConverter
//
//  Created by Nicolás Miari on 2019/10/04.
//  Copyright © 2019 Nicolás Miari. All rights reserved.
//

import UIKit

/**
 Based on my own public proof-of-concept repository: https://github.com/nicolas-miari/EditableButton
 */
class InputButton: UIButton, UITextInputTraits {

    // MARK: - UITextInputTraits
    var autocapitalizationType: UITextAutocapitalizationType = .none
    var autocorrectionType: UITextAutocorrectionType         = .no
    var spellCheckingType: UITextSpellCheckingType           = .no
    var enablesReturnKeyAutomatically: Bool                  = false
    var keyboardAppearance: UIKeyboardAppearance             = .default
    var keyboardType: UIKeyboardType                         = .default
    var returnKeyType: UIReturnKeyType                       = .default
    var textContentType: UITextContentType!

    // MARK: - UIResponder
    private var customInputView: UIView?

    override var inputView: UIView? {
        get {
            return customInputView
        }
        set (newValue) {
            customInputView = newValue
        }
    }

    private var customInputAccessoryView: UIView?

    override var inputAccessoryView: UIView? {
        get {
            return customInputAccessoryView
        }
        set (newValue) {
            customInputAccessoryView = newValue
        }
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }

    // MARK: - Initialization

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addTarget(self, action: #selector(InputButton.tap(_:)), for: .touchDown)
    }

    // MARK: - Control Actions

    @IBAction func tap(_ sender: UIButton) {
        self.becomeFirstResponder()
    }
}
