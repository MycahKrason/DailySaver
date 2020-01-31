//
//  SetBudgetViewController.swift
//  DailyWallet
//
//  Created by Mycah on 6/17/18.
//  Copyright © 2018 Mycah Krason. All rights reserved.
//

import UIKit

class SetBudgetViewController: UIViewController, UITextFieldDelegate {

    //Outlets
    @IBOutlet weak var stackViewDisplay: UIStackView!
    @IBOutlet weak var numberOfDaysInput: UITextField!
    @IBOutlet weak var amountOfMoneyToSpendInput: UITextField!
    let defaults = UserDefaults.standard
    
    var amountOfMoneyToSpendBottomAnchor : NSLayoutConstraint?
    var stackViewDisplayBottomAnchor: NSLayoutConstraint?
    
    var budgetSetTimes : Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideKeyboardWhenTappedAround()
        setupKeyboardObservers()
        
        amountOfMoneyToSpendInput.translatesAutoresizingMaskIntoConstraints = false
        amountOfMoneyToSpendBottomAnchor?.isActive = true
        
        //Retrieve the budgetSetTimes from the defaults
        budgetSetTimes = defaults.double(forKey: "BudgetSetTimes")

    }

    @IBAction func updateBudgetBtn(_ sender: Any) {
        
        //create the average amount of days and save it
        if numberOfDaysInput.text == "" || numberOfDaysInput.text == "." || amountOfMoneyToSpendInput.text == "" || amountOfMoneyToSpendInput.text == "."{
            
            //Alert will pop up to say they do not have enough money
            let alertController = UIAlertController(title: nil, message:"All fields must be filled in.", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
            self.present(alertController, animated: true, completion: nil)
            
        }else{
            
            //Check the budgetSetTimes, if budgetSetTimes is equal to 2, show an add and then reset budgetSetTimes back to 0
            if budgetSetTimes == nil{
                //this is the first time that a budget has been set
                budgetSetTimes = 0
                defaults.set(budgetSetTimes, forKey: "BudgetSetTimes")
            }else{
                budgetSetTimes! += 1
                defaults.set(budgetSetTimes, forKey: "BudgetSetTimes")
                print("Budget Set Times has increased = \(budgetSetTimes!)")
                
            }
            
            //Store the information provided in the money and days textfields
            let numberOfDays : Double? = Double(numberOfDaysInput.text!)
            let amountOfMoney : Double? = Double(amountOfMoneyToSpendInput.text!)
            let lastSavedDay : Double? = numberOfDays
            
            defaults.set(numberOfDays, forKey: "NumberOfDays") //Double
            defaults.set(lastSavedDay, forKey: "LastSavedDay") //Double
            defaults.set(amountOfMoney, forKey: "AmountOfMoney") //Double
            
            let todaysBudget : Double = (amountOfMoney! / numberOfDays!)
            defaults.set(todaysBudget, forKey: "TodaysBudget") //Double
            
            //Set the time count down
            let startDate = Date()
            defaults.set(startDate, forKey: "StartDate")
            
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    //**************
    //MARK:Keyboards
    //**************
    
    //Setup the keyboard observers
    func setupKeyboardObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func handleKeyboardWillShow(notification: NSNotification) {
        
        //Check for which textfield is active
        if amountOfMoneyToSpendInput.isEditing{
        
            numberOfDaysInput.isUserInteractionEnabled = false
            
            if let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                //Get keyboard duration
                let keyboardDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! Double
               
                amountOfMoneyToSpendInput.translatesAutoresizingMaskIntoConstraints = false
                
                //Move input field to correct height
                amountOfMoneyToSpendBottomAnchor = amountOfMoneyToSpendInput.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -keyboardFrame.height - 8)
                amountOfMoneyToSpendBottomAnchor?.isActive = true
                
                //Adjust the stack view
                stackViewDisplay.translatesAutoresizingMaskIntoConstraints = false
                
                //Adjust the stack view
                stackViewDisplayBottomAnchor = stackViewDisplay.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -keyboardFrame.height + 45)
                stackViewDisplayBottomAnchor?.isActive = true
                
                //Animate input field to move with keyboard
                UIView.animate(withDuration: keyboardDuration, animations: {
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    
    @objc func handleKeyboardWillHide(notification: NSNotification) {
        let keyboardDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! Double
        
        amountOfMoneyToSpendInput.isUserInteractionEnabled = true
        numberOfDaysInput.isUserInteractionEnabled = true
        
        //Move input field to correct height
        amountOfMoneyToSpendBottomAnchor?.isActive = false
        stackViewDisplayBottomAnchor?.isActive = false
        
        //Animate input field to move with keyboard
        UIView.animate(withDuration: keyboardDuration, animations: {
            self.view.layoutIfNeeded()
        })
    }
}
