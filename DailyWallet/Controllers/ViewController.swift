//
//  ViewController.swift
//  DailyWallet
//
//  Created by Mycah on 6/16/18.
//  Copyright © 2018 Mycah Krason. All rights reserved.
//

import UIKit
import GoogleMobileAds

class ViewController: UIViewController, UITextFieldDelegate {

    //Outlets
    @IBOutlet weak var daysRemainingDisplay: UILabel!
    @IBOutlet weak var moneyForTheDayDisplay: UILabel!
    @IBOutlet weak var subtractMoneyDisplay: UITextField!
    @IBOutlet weak var infoBtnDisplay: UIButton!
    
    @IBOutlet weak var bannerDisplay: GADBannerView!
    var interstitial: GADInterstitial!
    
    //Visual Outlets
    @IBOutlet weak var spendMoneyBtnDisplay: UIButton!
    @IBOutlet weak var stackViewDisplay: UIStackView!
    
    let defaults = UserDefaults.standard
    
    var daysFromDefaults : Double = 0
    var amountOfMoneyFromDefaults : Double = 0
    var dateFromDefaults : Date?
    var todaysBudget : Double = 0
    var lastSavedDay: Double = 0
    var budgetSetTimes : Double?
    
    
    //Dates
    var startDate : Date?
    var endDate : Date?
    
    var subtractMoneyDisplayBottomAnchor : NSLayoutConstraint?
    var stackViewDisplayBottomAnchor : NSLayoutConstraint?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        interstitial = createAndLoadInterstitial()
        
        //Set up the ad banner
        //TODO: change this to a DEPLOYMENT adUnitID
        //TEST
        //bannerDisplay.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        //Legit
        bannerDisplay.adUnitID = Private().AD_BANNER_ID
        
        bannerDisplay.rootViewController = self
        bannerDisplay.load(GADRequest())
        
        //Load an add
        //TODO: change the addID before launch
        //Legit
        //interstitial = GADInterstitial(adUnitID: "ca-app-pub-8395326091077015/6500367931")
        
        //set image size aspect
        infoBtnDisplay.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        infoBtnDisplay.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5)
      
        self.subtractMoneyDisplay.delegate = self
        
        hideKeyboardWhenTappedAround()
        setupKeyboardObservers()
        
    }
    
    func createAndLoadInterstitial() -> GADInterstitial {
        //Test
        //interstitial = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910")
        //Legit
        interstitial = GADInterstitial(adUnitID: Private().AD_INTERSTITIAL_ID)
        
        interstitial.load(GADRequest())
        return interstitial
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        interstitial = createAndLoadInterstitial()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //Update base on user Defaults
        daysFromDefaults = defaults.double(forKey: "NumberOfDays")
        amountOfMoneyFromDefaults = defaults.double(forKey: "AmountOfMoney")
        dateFromDefaults = defaults.object(forKey: "StartDate") as? Date
        todaysBudget = defaults.double(forKey: "TodaysBudget")
        lastSavedDay = defaults.double(forKey: "LastSavedDay")
        
        daysRemaining()
        
    }
    
    func daysRemaining(){
        
        //Show the ad
        budgetSetTimes = defaults.double(forKey: "BudgetSetTimes")
        if budgetSetTimes == 2{
            budgetSetTimes = 0
            defaults.set(budgetSetTimes, forKey: "BudgetSetTimes")
            print("TIMES!!!! \(budgetSetTimes!)")
            //Show the ad
            if interstitial.isReady {
                interstitial.present(fromRootViewController: self)
            } else {
                print("Ad wasn't ready")
            }
        }
        
        //get Current Date
        if dateFromDefaults == nil{
            daysRemainingDisplay.text = "0"
        }else{
            startDate = dateFromDefaults
            endDate = Date()
            print(startDate!)
            print(endDate!)
            
            //get the elapsed time
            let elapsedTime : TimeInterval = endDate!.timeIntervalSince(startDate!)
            let minutes = (elapsedTime / 60)
            let days = (minutes / 60 / 24)
            let flooredDays = floor(days)
            
            print("OH I SEE DAYS \(days)")
            print("HEY!! \(flooredDays)")
            
            daysFromDefaults -= flooredDays
            
            if daysFromDefaults < lastSavedDay{
                lastSavedDay = daysFromDefaults
                defaults.set(lastSavedDay, forKey: "LastSavedDay")
                
                //update the daily budget to reflect the average of daysfromdefaults and amount of money from defaults
                todaysBudget = (amountOfMoneyFromDefaults / daysFromDefaults)
                defaults.set(todaysBudget, forKey: "TodaysBudget")
                
            }
            
            if daysFromDefaults <= 0{
                daysRemainingDisplay.text = "No More days"
                
            }else{
                let daysFromDefaultsString : String = String(format: "%.0f", daysFromDefaults)
                daysRemainingDisplay.text = daysFromDefaultsString
                
            }
        }
        
        let formattedMoney = String(format: "%.2f", todaysBudget)
        moneyForTheDayDisplay.text = "$\(formattedMoney)"
        
    }
    
    @IBAction func spendMoneyBtn(_ sender: Any) {

        //get amount of money from input
        let subtractMoney : Double? = Double(subtractMoneyDisplay.text!)
        
        //Check to make sure the input field is not empty
        if subtractMoneyDisplay.text == "" || subtractMoneyDisplay.text == "."{
            
            //Alert will pop up to say they do not have enough money
            let alertController = UIAlertController(title: nil, message:"You must enter a valid number.", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
            self.present(alertController, animated: true, completion: nil)
            
        }else{
            
            if (todaysBudget - subtractMoney!) < 0{
                //Alert will pop up to say they do not have enough money
                let alertController = UIAlertController(title: nil, message:"You have spent all of your money for today.", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                self.present(alertController, animated: true, completion: nil)
                
            }
            
            amountOfMoneyFromDefaults -= subtractMoney!
            
            //Show that money is being subtracted from the daily amount
            todaysBudget -= subtractMoney!
            let formattedMoney = String(format: "%.2f", todaysBudget)
            moneyForTheDayDisplay.text = "$\(formattedMoney)"
            defaults.set(todaysBudget, forKey: "TodaysBudget")
            
            //Update the money is user defaults
            defaults.set(amountOfMoneyFromDefaults, forKey: "AmountOfMoney")
            
            //clear the text field
            subtractMoneyDisplay.text = ""
        }
    }
    
    //***************
    //MARK: Keyboards
    //***************
    
    //Setup the keyboard observers
    func setupKeyboardObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func handleKeyboardWillShow(notification: NSNotification) {
        
        if let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            //Get keyboard duration
            let keyboardDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! Double
            
            subtractMoneyDisplay.translatesAutoresizingMaskIntoConstraints = false
            stackViewDisplay.translatesAutoresizingMaskIntoConstraints = false

            //Adjust the stack view
            stackViewDisplayBottomAnchor = stackViewDisplay.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -keyboardFrame.height + 50)
            stackViewDisplayBottomAnchor?.isActive = true
            
            //Move input field to correct height
            subtractMoneyDisplayBottomAnchor = subtractMoneyDisplay.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -keyboardFrame.height - 8)
            subtractMoneyDisplayBottomAnchor?.isActive = true
            
            //Animate input field to move with keyboard
            UIView.animate(withDuration: keyboardDuration, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @objc func handleKeyboardWillHide(notification: NSNotification) {
        let keyboardDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! Double
        
        //Move input field to correct height
        subtractMoneyDisplayBottomAnchor?.isActive = false
        stackViewDisplayBottomAnchor?.isActive = false
        
        //Animate input field to move with keyboard
        UIView.animate(withDuration: keyboardDuration, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    //This will make sure there is only one decimal and the user can only input 2 decimal places
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        switch string {
        case "0","1","2","3","4","5","6","7","8","9":
            return true
        case ".":
            let array = Array(subtractMoneyDisplay.text!)
            var decimalCount = 0
            for character in array {
                if character == "." {
                    decimalCount += 1
                }
            }
            
            if decimalCount == 1{
                return false
            } else{
                return true
            }
            
        default:
            let array = Array(string)
            if array.count == 0 {
                return true
            }
            return false
        }
    }
}


