//
//  ConverterViewController.swift
//  CurrencyConverter
//
//  Created by Nicolás Miari on 2019/10/04.
//  Copyright © 2019 Nicolás Miari. All rights reserved.
//

import UIKit

/**
 Main app screen. Coordinates the graphical user interface (input and display controls) with the web
 service and additional local business logic.
 */
class ConverterViewController: UIViewController {

    // MARK: - GUI

    @IBOutlet weak var inputAmountLabel: NumericInputLabel!
    @IBOutlet weak var inputCurrencyButton: InputButton!

    @IBOutlet weak var swapCurrenciesButton: UIButton!

    @IBOutlet weak var convertedCurrencyButton: InputButton!
    @IBOutlet weak var convertedAmountLabel: UILabel!

    // MARK: -

    lazy var viewModel: ConverterViewModel = {
        guard let viewModel = try? ConverterViewModel() else {
            fatalError("!!!")
        }
        return viewModel
    }()

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        inputAmountLabel.customInputAccessoryView = keyPadAccessoryView()
        inputAmountLabel.delegate = self

        let inputCurrencyInputView = currencyInputView()
        inputCurrencyInputView.selectRow(viewModel.inputCurrencyIndex, inComponent: 0, animated: false)
        inputCurrencyButton.inputView = inputCurrencyInputView
        inputCurrencyButton.inputAccessoryView = currencyAccessoryView()

        let convertedCurrencyInputView = currencyInputView()
        convertedCurrencyInputView.selectRow(viewModel.convertedCurrencyIndex, inComponent: 0, animated: false)
        convertedCurrencyButton.inputView = convertedCurrencyInputView
        convertedCurrencyButton.inputAccessoryView = currencyAccessoryView()

        updateButtonTitles()
    }

    private func keyPadAccessoryView() -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 44))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray4

        let button = UIButton(type: .system)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Convert", for: .normal)
        button.addTarget(self, action: #selector(convert(_:)), for: .touchUpInside)
        view.addSubview(button)
        button.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        button.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true

        return view
    }

    private func currencyInputView() -> UIPickerView {
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        return picker
    }

    private func currencyAccessoryView() -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 44))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray5

        let cancelButton = UIButton(type: .system)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.addTarget(self, action: #selector(cancel(_:)), for: .touchUpInside)
        view.addSubview(cancelButton)
        cancelButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        cancelButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true

        let doneButton = UIButton(type: .system)
        doneButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.setTitle("Done", for: .normal)
        doneButton.addTarget(self, action: #selector(done), for: .touchUpInside)
        view.addSubview(doneButton)
        doneButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        doneButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true

        return view
    }

    private func updateButtonTitles() {
        inputCurrencyButton.setTitle(viewModel.inputCurrency.code, for: .normal)
        convertedCurrencyButton.setTitle(viewModel.convertedCurrency.code, for: .normal)
    }

    private func executeConversion() {
        inputAmountLabel.resignFirstResponder()

        guard let amount = Double(inputAmountLabel.text ?? "") else {
            fatalError("Invalid Input")
        }

        // Skip trivial conversions (0 input, or same currency):
        guard amount > 0.0, viewModel.inputCurrency.code != viewModel.convertedCurrency.code else {
            self.convertedAmountLabel.text = inputAmountLabel.text
            return
        }

        ConversionService.shared.convert(
            amount: amount,
            from: viewModel.inputCurrency.code,
            to: viewModel.convertedCurrency.code,
            completion: { [weak self](result) in

                self?.convertedAmountLabel.text = String(format: "%.2f", result)

        }, failure: { [weak self] (error) in
            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self?.present(alert, animated: true, completion: nil)
        })
    }

    // MARK: - Control Actions

    @objc func cancel(_ sender: Any) {
        UIResponder.first?.resignFirstResponder()
    }

    @objc func done(_ sender: Any) {
        guard let firstResponder = UIResponder.first else {
            return
        }
        guard let picker = firstResponder.inputView as? UIPickerView else {
            fatalError("Control Inconsistency")
        }
        let row = picker.selectedRow(inComponent: 0)

        // Update view model based on picker and selected row:
        switch firstResponder {
        case inputCurrencyButton:
            viewModel.inputCurrencyIndex = row

        case convertedCurrencyButton:
            viewModel.convertedCurrencyIndex = row

        default:
            break
        }
        updateButtonTitles()

        // Dismiss picker...
        firstResponder.resignFirstResponder()

        // ...and recalculate conversion:
        executeConversion()
    }

    @objc func convert(_ sender: Any) {
        executeConversion()
    }

    @IBAction func selectSourceCurrency(_ sender: Any) {
    }

    @IBAction func selectDestinationCurrency(_ sender: Any) {
    }

    @IBAction func swapCurrencies(_ sender: Any) {
        // [1] Swap contents of view model
        let tempIndex = viewModel.inputCurrencyIndex
        viewModel.inputCurrencyIndex = viewModel.convertedCurrencyIndex
        viewModel.convertedCurrencyIndex = tempIndex

        // [2] Swap label text and button titles
        let tempAmount = inputAmountLabel.text
        inputAmountLabel.text = convertedAmountLabel.text
        convertedAmountLabel.text = tempAmount

        updateButtonTitles()

        // [3] Update selected rows of the (hodden) picker views:
        (inputCurrencyButton.inputView as? UIPickerView)?.selectRow(viewModel.inputCurrencyIndex, inComponent: 0, animated: false)
        (convertedCurrencyButton.inputView as? UIPickerView)?.selectRow(viewModel.convertedCurrencyIndex, inComponent: 0, animated: false)
    }
}

// MARK: - NumericInputLabelDelegate

extension ConverterViewController: NumericInputLabelDelegate {
    func numericInputLabel(_ label: NumericInputLabel, shouldChangeToText proposedText: String) -> Bool {
        return viewModel.isValidInputText(proposedText)
    }
}

extension ConverterViewController: UIPickerViewDelegate {

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let currency = viewModel.currency(at: row)
        return "\(currency.name) (\(currency.code))"
    }
}

extension ConverterViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return viewModel.numberOfCurrencies
    }
}
