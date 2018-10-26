//
//  SignInViewController.swift
//  zzApp
//
//  Created by Alvar Aronija on 2018-10-04.
//  Copyright © 2018 Alvar Aronija. All rights reserved.
//

import UIKit
import Eureka
import FacebookLogin
import UserNotifications

class SignInViewController: FormViewController {
    // MARK: - Properties
    private let serverOps = ServerOps()
    
    var valuesDictionary: [String: Any]?
    let dataHelper = DataProvider()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { (request) in
//            print(request)
        }
        showForm()
        registerLocal()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// MARK: - Actions
private extension SignInViewController {
    
    @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
        print("Cancel tapped")
        LoginManager().logOut()
        dismiss(animated: true, completion: nil)
        
        
    }
    
    @IBAction func saveTapped(_ sender: UIBarButtonItem) {
        print("Save tapped")
//        registerLocal()
        valuesDictionary = form.values()
        
        print(valuesDictionary)
        

        guard let name = valuesDictionary!["Name"] as? String,
            let email = valuesDictionary!["Email"] as? String,
            let sex = valuesDictionary!["Sex"] as? String,
            let age = valuesDictionary!["Age"] as? Int,
            let country = valuesDictionary!["Country"] as? String,
            let reminder = valuesDictionary!["Reminder"] as? Date,
            let startDate = valuesDictionary!["StartDate"] as? Date,
            let customerId = valuesDictionary!["CustomerID"] as? Int else {
                print("Could not parse values")
                return
        }
        let dailyReminder = reminder.convertTo(region: .current).toFormat("HH:mm")
        print(dailyReminder)
        print(dailyReminder.components(separatedBy: ":"))
        User.sharedInstance.customerID = String(customerId)
        User.sharedInstance.name = name
        User.sharedInstance.email = email
        User.sharedInstance.sex = sex.sex().rawValue
        User.sharedInstance.age = age
        User.sharedInstance.country = country.code().rawValue
        User.sharedInstance.dailyReminder = reminder.convertTo(region: .current).toFormat("HH:mm")
        User.sharedInstance.startDate = startDate.convertTo(region: .current).toFormat("yyyy-dd-MM")
        dataHelper.saveUser(User.sharedInstance)
        scheduleLocal()
        
        if User.sharedInstance.appId == "" {
            
            serverOps.onDataLoad = { [weak self] (data) in
                self?.useData(data: data)
                
            }
            serverOps.loginWith(customerID: String(customerId))
        } else {
            performSegue(withIdentifier: "unwindSegueToLogin", sender: self)
        }
        
    }

    func useData(data: JSON) {
        print("Received data: ")
        print(data)
        let status = data["status"].stringValue
        User.sharedInstance.appId = data["iUserID"].stringValue
        print(status)
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "unwindSegueToLogin", sender: self)
        }
    }
    
    func showForm() {
        
        PickerInlineRow<String>.InlineRow.defaultCellUpdate = { cell, _ in
            cell.backgroundColor = .black
            
        }
        
        IntRow.defaultCellUpdate = { cell, row in
            cell.textLabel?.textColor = Theme.current.textColor
            cell.textField.textColor = Theme.current.textColor
        }
        
        form +++ Section("User info")
            
            <<< IntRow("CustomerID") {
                $0.title = "Customer ID"
                $0.value = Int(User.sharedInstance.customerID)
                $0.placeholder = "Insert ID"
                $0.placeholderColor = .gray
            }
            
            <<< NameRow("Name") {
                $0.title = "Name"
                $0.value = User.sharedInstance.name
                $0.placeholder = "Insert name"
                $0.placeholderColor = .gray
                }.cellUpdate({ (cell, row) in
                    cell.textLabel?.textColor = Theme.current.textColor
                    cell.textField.textColor = Theme.current.textColor
                })
            <<< EmailRow("Email") {
                $0.title = "Email"
                $0.value = User.sharedInstance.email
                $0.placeholder = "Insert email"
                $0.placeholderColor = .gray
                }.cellUpdate({ (cell, row) in
                    cell.textLabel?.textColor = Theme.current.textColor
                    cell.textField.textColor = Theme.current.textColor
                })
            <<< ActionSheetRow<String>("Sex") {
                $0.title = "Sex"
                $0.options = ["Female", "Male", "Other"]
                $0.value = "Select sex"
                $0.selectorTitle = "Select sex"
                }.cellUpdate({ (cell, row) in
                    cell.textLabel?.textColor = Theme.current.textColor
                })
            
            <<< IntRow("Age") {
                $0.title = "Age"
                $0.placeholder = "Insert age"
                $0.placeholderColor = .gray
            }
            
            //            <<< PickerInlineRow<String>("Country") {
            //                $0.title = "Country"
            //                $0.options = ["Sweden", "Norway", "Finland", "Denmark", "Faroe Islands", "Iceland", "Estonia", "Latvia", "Lithuania", "Spain"]
            //                $0.value = "Sweden"
            //                }.cellUpdate({ (cell, row) in
            //
            //                    cell.textLabel?.textColor = Theme.current.textColor
            //                    cell.detailTextLabel?.textColor = Theme.current.textColor
            //
            //                })
            <<< TextRow("Country") {
                $0.title = "Country"
                $0.placeholder = "Insert country"
                $0.placeholderColor = .gray
                }.cellUpdate({ (cell, row) in
                    cell.textLabel?.textColor = Theme.current.textColor
                    cell.textField.textColor = Theme.current.textColor
                    
                })
            
            +++ Section("Daily Reminder")
            <<< TimeRow("Reminder") {
                $0.title = "Current reminder"
                $0.value = Date()
                }.cellUpdate({ (cell, row) in
                    cell.textLabel?.textColor = Theme.current.textColor
                })
            
            +++ Section("When did you start to take the Balance products?")
            <<< DateRow("StartDate") {
                $0.title = "Start date"
                $0.value = Date()
                
                }.cellUpdate({ (cell, row) in
                    cell.textLabel?.textColor = Theme.current.textColor
                })
    }
}

extension SignInViewController: UNUserNotificationCenterDelegate {
    
    func scheduleLocal() {
        let center = UNUserNotificationCenter.current()
//        center.removeAllPendingNotificationRequests()
//        print("Removed old reminder and scheduled a new reminder")
        let notificationManager = LocalNotification()
        
        let date = User.sharedInstance.dailyReminder.toDate("HH:mm", region: .current)
        notificationManager.scheduleLocal(hour: date!.hour, minute: date!.minute)
    }
    
    func registerLocal() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("Permission granted")
//                self.showDatePicker()
            } else {
                print(error!.localizedDescription)
            }
        }
        
    }
}
