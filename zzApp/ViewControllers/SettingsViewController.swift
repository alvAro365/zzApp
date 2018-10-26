//
//  SettingsViewController.swift
//  LocalNotifications
//
//  Created by Alvar Aronija on 2018-09-10.
//  Copyright © 2018 Alvar Aronija. All rights reserved.
//

import UIKit
import UserNotifications
import FacebookLogin

class SettingsViewController: UITableViewController {
    
    // MARK: - Properties
    let dataHelper = DataProvider()
    var dailyReminder: String?
    let datePicker = UIDatePicker()
    let serverOps = ServerOps()
    let amountOfHealthPoints = 0

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        Theme(rawValue: 2)?.apply()
        navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(showActionSheet))
        navigationItem.rightBarButtonItem = nil

        datePicker.datePickerMode = .time
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { (request) in
//            print(request)
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Navigation
    @IBAction func unwindToSettings(_ sender: UIStoryboardSegue) {
        scheduleLocal()
        tableView.reloadData()
    }
    
}

// MARK: - DataSource
extension SettingsViewController {
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let themeCell = tableView.dequeueReusableCell(withIdentifier: "ThemeCell", for: indexPath) as! ThemeTableViewCell
        
        if indexPath.section == 0 {
            cell.textLabel?.text = "Daily reminder"
            cell.detailTextLabel?.text = User.sharedInstance.dailyReminder
            
        }
        
        if indexPath.section == 1 && indexPath.row == 0 {
            cell.textLabel?.text = "App ID"
            cell.detailTextLabel?.text = User.sharedInstance.appId
            cell.accessoryType = .none
            cell.selectionStyle = .none
            
            
        }
        if indexPath.section == 1 && indexPath.row == 1 {
            cell.textLabel?.text = "App registaration date"
            cell.detailTextLabel?.text = User.sharedInstance.appRegDate
            cell.accessoryType = .none
            cell.selectionStyle = .none
            
            
        }
        
//        if indexPath.section == 1 && indexPath.row == 2 {
//            cell.textLabel?.text = "HealthPoints"
//            //            cell.detailTextLabel?.text = String(User.sharedInstance.productHealthPoints + User.sharedInstance.stepHealthPoints)
//            cell.detailTextLabel?.text = String(dataHelper.getTotalHealthPoints())
//            cell.accessoryType = .none
//            cell.selectionStyle = .none
//        }
        
        if indexPath.section == 2 && indexPath.row == 0 {
            themeCell.theme.text = "Dark"
            themeCell.themeSwitch.isOn = UserDefaults.standard.integer(forKey: "SelectedTheme") == 0 ? false : true
            themeCell.selectionStyle = .none
            return themeCell
            
        }
        cell.backgroundColor = Theme.current.backgroundColor
        cell.textLabel?.textColor = Theme.current.textColor
        cell.detailTextLabel?.textColor = Theme.current.textColor
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 2
        case 2:
            return 1
        default:
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Reminder"
        case 1:
            return "Info"
        case 2:
            return "Theme"
        default:
            return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.backgroundView?.backgroundColor = Theme.current.backgroundColor
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            registerLocal()
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension SettingsViewController:  UNUserNotificationCenterDelegate {
    
    func scheduleLocal() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        print("Removed old reminder and scheduled a new reminder")
        let notificationManager = LocalNotification()
        
        let date = User.sharedInstance.dailyReminder.toDate("HH:mm", region: .current)
        notificationManager.scheduleLocal(hour: date!.hour, minute: date!.minute)
    }
    
    func registerLocal() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("Permission granted")
                self.showDatePicker()
            } else {
                print(error!.localizedDescription)
            }
        }
        
    }
}

// MARK: - Actions
private extension SettingsViewController {
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        dailyReminder = sender.date.in(region: .current).toFormat("HH:mm")
    }
    
    func showDatePicker() {
        let datePickerAlert = UIAlertController(title: "Choose new time to be reminded", message: nil, preferredStyle: .actionSheet)
        datePickerAlert.view.addSubview(datePicker)
        datePickerAlert.addAction(UIAlertAction(title: "Done", style: .cancel, handler: { (action) in
            print("Done clicked")
            self.dataHelper.saveDailyReminder(hourAndMinutes: self.dailyReminder ?? User.sharedInstance.dailyReminder)
            print(User.sharedInstance.dailyReminder)
            self.tableView.reloadData()
            self.scheduleLocal()
            self.showSaveAlert()
        }))
        
        let height = NSLayoutConstraint(item: datePickerAlert.view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: datePickerAlert.view.bounds.height/2)
        
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.centerXAnchor.constraint(equalTo: datePickerAlert.view.centerXAnchor).isActive = true
        datePicker.centerYAnchor.constraint(equalTo: datePickerAlert.view.centerYAnchor).isActive = true
        
        datePickerAlert.view.addConstraint(height)
        
        self.present(datePickerAlert, animated: true, completion: nil)
    }
    
    @objc func showActionSheet() {
        print("Action button pressed")
        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        ac.addAction(UIAlertAction(title: "Sign out", style: .destructive, handler: { _ in
            print("Log me out pressed")
            self.logOutClicked()
        }))
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            print("Cancel pressed")
        }))
        present(ac, animated: true)
    }
    
    
    
    func logOutClicked() {
        let loginManager = LoginManager()
        loginManager.logOut()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "LoginVC")
        let navController = UINavigationController.init(rootViewController: vc)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = navController
        
    }
    
    func useData(data: JSON) {
        DispatchQueue.main.async {
            self.dataHelper.saveUser(User.sharedInstance)
            self.tableView.reloadData()
        }
    }
    
    func showSaveAlert() {
        let saveAlert = UIAlertController(title: "Saved!", message: "", preferredStyle: .alert)
        present(saveAlert, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            saveAlert.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func selectTheme(_ sender: UISwitch) {
        var themeIndex = -1
        sender.isOn ? (themeIndex = 1) : (themeIndex = 0)
        
        if let selectedTheme = Theme(rawValue: themeIndex) {
            selectedTheme.apply()
        }
        self.tabBarController?.tabBar.barStyle = Theme.current.barStyle
        self.navigationController?.navigationBar.barStyle = Theme.current.barStyle
//        self.navigationController?.navigationBar.tintColor = Theme.current.textColor
        self.tableView.backgroundColor = Theme.current.backgroundColor
        tableView.reloadData()
    }
}
