//
//  ConverterViewController.swift
//  CurrencyConverter
//
//  Created by Nicolás Miari on 2019/10/04.
//  Copyright © 2019 Nicolás Miari. All rights reserved.
//

import UIKit

class ConverterViewController: UIViewController {

    // MARK: - GUI

    @IBOutlet weak var sourceAmountLabel: NumericInputLabel!
    @IBOutlet weak var sourceCurrencyButton: InputButton!

    @IBOutlet weak var swapCurrenciesButton: UIButton!

    @IBOutlet weak var destinationCurrencyButton: InputButton!
    @IBOutlet weak var destinationAmountLabel: UILabel!

    let viewModel = ConverterViewModel()

    private var sourceCurrency: Currency? {
        didSet {
            sourceCurrencyButton?.setTitle(sourceCurrency?.code, for: .normal)
        }
    }

    private var destinationCurrency: Currency? {
        didSet {
            destinationCurrencyButton.setTitle(destinationCurrency?.code, for: .normal)
        }
    }

    private var temptativeSrcCurrency: Currency?
    private var temptativeDstCurrency: Currency?

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        sourceAmountLabel.customInputAccessoryView = keyPadAccessoryView()

        sourceCurrencyButton.inputView = currencInputView()
        sourceCurrencyButton.inputAccessoryView = currencyAccessoryView()

        destinationCurrencyButton.inputView = currencInputView()
        destinationCurrencyButton.inputAccessoryView = currencyAccessoryView()

        self.sourceCurrency = viewModel.currency(at: 0)
        (sourceCurrencyButton.inputView as? UIPickerView)?.selectRow(0, inComponent: 0, animated: false)

        self.destinationCurrency = viewModel.currency(at: 1)
        (destinationCurrencyButton.inputView as? UIPickerView)?.selectRow(1, inComponent: 0, animated: false)
    }

    private func keyPadAccessoryView() -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 44))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray4

        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Convert", for: .normal)
        button.addTarget(self, action: #selector(convert(_:)), for: .touchUpInside)
        view.addSubview(button)
        button.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        button.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8).isActive = true

        return view
    }

    private func currencInputView() -> UIView {
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
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.addTarget(self, action: #selector(cancel(_:)), for: .touchUpInside)
        view.addSubview(cancelButton)
        cancelButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        cancelButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8).isActive = true

        let doneButton = UIButton(type: .system)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.setTitle("Done", for: .normal)
        doneButton.addTarget(self, action: #selector(done), for: .touchUpInside)
        view.addSubview(doneButton)
        doneButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        doneButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8).isActive = true

        return view
    }

    // MARK: - Control Actions

    @objc func cancel(_ sender: Any) {
        UIResponder.first?.resignFirstResponder()
    }

    @objc func done(_ sender: Any) {
        guard let firstResponder = UIResponder.first else {
            return
        }
        switch firstResponder {
        case sourceCurrencyButton:
            self.sourceCurrency = temptativeSrcCurrency

        case destinationCurrencyButton:
            self.destinationCurrency = temptativeDstCurrency

        default:
            break
        }
        firstResponder.resignFirstResponder()
    }

    @objc func convert(_ sender: Any) {
        sourceAmountLabel.resignFirstResponder()

        //print("Converting \(sourceAmountLabel.text) \(sourceCurrency!.name) to \(destinationCurrency!.name)")
        /*
        ConversionService.shared.convert(amount: 10, from: "USD", to: "JPY") { (convertedAmount) in
            print("Converted: \(convertedAmount)")
        }
         */
    }

    @IBAction func selectSourceCurrency(_ sender: Any) {
    }

    @IBAction func selectDestinationCurrency(_ sender: Any) {
    }

    @IBAction func swapCurrencies(_ sender: Any) {
    }
}

extension ConverterViewController: UIPickerViewDelegate {

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
        case sourceCurrencyButton.inputView:
            self.temptativeSrcCurrency = viewModel.currency(at: row)

        case destinationCurrencyButton.inputView:
            self.temptativeDstCurrency = viewModel.currency(at: row)

        default:
            break
        }
    }

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
