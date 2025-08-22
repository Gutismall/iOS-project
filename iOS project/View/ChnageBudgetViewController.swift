//
//  ChnageBudgetViewController.swift
//  iOS project
//
//  Created by Ari Guterman on 22/08/2025.
//

import UIKit

protocol ChangeBudgetDelegate: AnyObject {
    func closeModal()
    func changeBudgetSuccessfully(budget:Int)
}

class ChnageBudgetViewController: UIViewController ,ChangeBudgetDelegate{
    
    lazy var modalView: ChnageBudgetModal = {
        let modalView = UINib(nibName: "ChangeBudgetModal", bundle: nil).instantiate(withOwner: nil)[0] as! ChnageBudgetModal
        modalView.delegate = self
        return modalView
    }()
    
    init(){
        super.init(nibName: nil, bundle: nil)
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        view.addSubview(modalView)
        modalView.translatesAutoresizingMaskIntoConstraints = false
        
        
        NSLayoutConstraint.activate([
            modalView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            modalView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            modalView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            modalView.heightAnchor.constraint(equalToConstant: 325)
        ])
        
    }
    
    func closeModal(){
        dismiss(animated: true)
    }
    
    func changeBudgetSuccessfully(budget:Int){
        UserViewModel.shared.setMonthlyBudget(budget: budget)
    }
    
}
