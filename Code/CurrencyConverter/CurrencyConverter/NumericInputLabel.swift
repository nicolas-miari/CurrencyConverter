//
//  NumericInputLabel.swift
//  NumericInputLabelDemo
//
//  Created by Nicolás Miari on 2019/08/07.
//  Copyright © 2019 Nicolás Miari. All rights reserved.
//

import UIKit

/**
 Text label that accepts text input as single-character tail-insertion or single-character tail-deletion only
 (much like the keypad of the phone app, or a calculator that allows you to remove digits in a last-in-first-out
 order).

 This is a minimalistic control: unlike `UITextField`, there is no visible/movable "cursor" (insertion/deletion
 always happens at the end) and it is not possible to select all or part of the text, let alone perform any
 copy/paste operations.

 The keyboard presented is always the **numeric pad**. When theuser taps a number key, that digit is added at the
 end of the label's text. When the user taps the 'delete key' (⌫), the last digit is removed. If that results in
 the empty string, then "0" is displayed instead. Conversely, when adding a new digit in this state --say, '7'--
 the leading zero is automatically removed, so the resulting text is "7", **not** "07": this is the expected
 behaviour for _numeric_ input.

 Because the control subclasses `UILabel`, every other aspect of the visual appearance and layout of text can be
 configured as usual.

 Taken from my own public proof-of-concept repository: https://github.com/nicolas-miari/Numeric-Input-Label
 */
class NumericInputLabel: UILabel, UITextInputTraits, UIKeyInput {

    // MARK: - Custom Configuration

    /**
     An optional object that gets notified of important text-change events, and get a chance
     to determine if they should be allowed or not.

     - seeAlso: NumericInputLabelDelegate
     */
    weak var delegate: NumericInputLabelDelegate?

    // MARK: - UITextInputTraits

    var autocapitalizationType: UITextAutocapitalizationType = .none
    var autocorrectionType: UITextAutocorrectionType = .no
    var spellCheckingType: UITextSpellCheckingType = .no
    var enablesReturnKeyAutomatically: Bool = false
    var keyboardAppearance: UIKeyboardAppearance = .default
    var keyboardType: UIKeyboardType = .decimalPad
    var returnKeyType: UIReturnKeyType = .default
    var textContentType: UITextContentType!

    // MARK: - UIKeyInput

    public func deleteBackward() {
        let text = self.text ?? ""
        guard !text.isEmpty else {
            return
        }
        let startIndex = text.startIndex
        let endIndex = text.index(before: text.endIndex)
        let shortenedText = String(text[startIndex ..< endIndex])

        let proposedText = shortenedText.isEmpty ? "0" : shortenedText
        // ('placeholder' text is zero)

        guard validateText(proposedText) else {
            return
        }
        self.text = proposedText
    }

    public func insertText(_ newText: String) {
        let current = text ?? ""

        let proposedText = current == "0" ? newText : current + newText
        // (removes the leading zero, if there is one)

        guard validateText(proposedText) else {
            return
        }
        self.text = proposedText
    }

    public var hasText: Bool {
        return !((text ?? "").isEmpty)
    }

    // MARK: - UIResponder

    override var canBecomeFirstResponder: Bool {
        return true
    }

    var customInputAccessoryView: UIView?

    override var inputAccessoryView: UIView? {
        return customInputAccessoryView
    }

    // MARK: - UIView

    /**
     Explicitly NOT overriding `isUserInteractionEnabled` to always return true. Leave is as
     configurable (programmatically, or in Interface Builder).
     Uncomment this property override if you see no use for selectively disabling input to
     instacnes of this class
     */
     /*
     override var isUserInteractionEnabled: Bool {
        set { }
        get { return true }
     }
     */

    // MARK: - UILabel

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    // MARK: - Internal Support

    private func setup() {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(tap(_:)))
        self.addGestureRecognizer(recognizer)
    }

    private func validateText(_ proposedText: String) -> Bool {
        guard let delegate = delegate else {
            // No delegate: Text is always valid.
            return true
        }
        return delegate.numericInputLabel(self, shouldChangeToText: proposedText)
    }

    @objc private func tap(_ recognizer: UITapGestureRecognizer) {
        self.becomeFirstResponder()
    }
}

// MARK: - Delegate Protocol

/**
 Protocol adopted by objects that wish to be consulted about important input events of one or more
 `NumericInputLabel` instances.

 Although seemingly minimal, this functionality is implemented as a protocol (as opposed to one or more closure
 properties of the `NumericInputLabel` class) to allow for complex method signatures and descriptive parameter
 labels.
 */
protocol NumericInputLabelDelegate: AnyObject {

    /**
     Called on the dleegate, if present, when the text is about to change due to keyboard input by
     the user (not called when the `text` property is modified programmatically).

     Returning `true` allows the change to take place immediately. Returning `false` causes the input to be
     ignored and the label's text to remain unchanged.

     - parameter label: The instance whose text is about to change due to keyboard input.
     - parameter proposedText: The displayed text that will result if the change is allowed to happen (i.e.,
     the method returns `true`).
     - returns: True if the proposed change is allowed to happen, `false` otherwise.
     */
    func numericInputLabel(_ label: NumericInputLabel, shouldChangeToText proposedText: String) -> Bool

}
