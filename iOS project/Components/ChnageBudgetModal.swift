//
//  ChnageBudgetModal.swift
//  iOS project
//
//  Created by Ari Guterman on 22/08/2025.
//

import UIKit


class ChnageBudgetModal: UIView {


    @IBOutlet weak var selectedBudgetLabel: UILabel!
    @IBOutlet weak var budgetSlider: UISlider!
    
    weak var delegate: ChangeBudgetDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        budgetSlider.minimumValue = 100   // Set your lower bound
        budgetSlider.maximumValue = 10000  // Set your upper bound
        selectedBudgetLabel.text = "Budget: \(Int(budgetSlider.value))"
        layer.cornerRadius = 8
    }
    
    @IBAction func onTapExit(_ sender: UIButton) {
        delegate?.closeModal()
    }
    @IBAction func onSliderChange(_ sender: UISlider) {
        let value = Int(sender.value)
        selectedBudgetLabel.text = "Budget: \(value)"
    }
    @IBAction func onTapSubmit(_ sender: Any) {
        print("Old budget \(UserViewModel.shared.user.monthlyBudget)")
        delegate?.changeBudgetSuccessfully(budget: Int(budgetSlider.value))
        print("selected value is \(budgetSlider.value)")
        print("New budget set \(UserViewModel.shared.user.monthlyBudget)")
        delegate?.closeModal()
    }
}
