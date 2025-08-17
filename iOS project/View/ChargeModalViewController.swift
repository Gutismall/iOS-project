//
//  ChargeModalViewController.swift
//  iOS project
//
//  Created by Ari Guterman on 10/08/2025.
//

import UIKit
import FirebaseCore
import FirebaseAuth

protocol ChargeModalDelegate: AnyObject {
    func didCreateCharge(_ charge: Charge)
}

class ChargeModalViewController: UIViewController,UIPickerViewDataSource,UIPickerViewDelegate{
    
    
    @IBOutlet weak var categoryPicker: UIPickerView!
    @IBOutlet weak var chargeNameField: UITextField!
    @IBOutlet weak var amountField: UITextField!
    
    let categories = ChargeCategory.allCases
    weak var delegate: ChargeModalDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        categoryPicker.dataSource = self
        categoryPicker.delegate = self

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories[row].displayName
    }
    
    @IBAction func onTapCreate(_ sender: Any) {
        print("Creating Charge")
        guard
            let name = chargeNameField.text, !name.isEmpty,
            let amountText = amountField.text, let amount = Double(amountText)
        else { return }
        
        let selectedCategory = categories[categoryPicker.selectedRow(inComponent: 0)]
        let charge = Charge(
            id: UUID().uuidString,
            amount: amount,
            description: name,
            createdByName: Auth.auth().currentUser?.displayName ?? "",
            category: selectedCategory,
            timestamp: Timestamp(date: Date())
        )
        delegate?.didCreateCharge(charge)
        dismiss(animated: true, completion: nil)
    }
    
    
}
