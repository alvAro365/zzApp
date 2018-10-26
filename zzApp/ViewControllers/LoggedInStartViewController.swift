//
//  LoggedInStartViewController.swift
//  zzApp
//
//  Created by Alvar Aronija on 2018-09-06.
//  Copyright © 2018 Alvar Aronija. All rights reserved.
//

import UIKit
import FacebookLogin
import FacebookCore
import HealthKit
import UserNotifications
import Charts

class LoggedInStartViewController: UIViewController {
    
    // MARK: - Properties
    private let healthKit = HealthKit()
    private let dataHelper = DataProvider()
    private let serverOps = ServerOps()
    private var toggleTitle = false
    let notificationCenter = UNUserNotificationCenter.current()
    var dataSet: PieChartDataSet?
    var stepsToday: Double = 0
    
    // MARK: - Outlets
    @IBOutlet weak var countOfSteps: UILabel!
    @IBOutlet weak var countOfHealthPoints: UILabel!
    @IBOutlet weak var toNextLevel: UILabel!
    @IBOutlet weak var currentLevelLabel: UILabel!
    @IBOutlet weak var pieChart: PieChartView!
    @IBOutlet weak var toggleButton: UIBarButtonItem!
    
    
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.titleTapped))
        navigationController?.navigationBar.addGestureRecognizer(tapGestureRecognizer)
        navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        notificationCenter.delegate = self
        healthKit.delegate = self
        healthKit.getDailySteps()
        navigationItem.setHidesBackButton(true, animated: true)
        self.title = "Steps"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        pieChartUpdate()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

    // MARK: HealthKitDelegate
extension LoggedInStartViewController: HealthKitDelegate {
    func didReceiveDataUpdate(data: Double) {
        print("Data updated: " + String(data))
        self.stepsToday = data
        
        DispatchQueue.main.async {
            self.pieChartUpdate()
            self.setupViews()
        }
    }
}

// MARK: UNUserNotificationCenterDelegate
extension LoggedInStartViewController: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        if let customData = userInfo["customData"] as? String {
            print("Custom data received: " + customData)
            switch response.actionIdentifier {
            case UNNotificationDefaultActionIdentifier:
                let ac = UIAlertController(title: nil, message: "Did you take your Balance product today?", preferredStyle: .actionSheet)
                ac.addAction(UIAlertAction(title: "Oh yeah!", style: .default, handler: { (action) in
                    print("Yes")
                    self.dataHelper.addAndSaveHealthPoint(identifier: "Product")
                    self.serverOps.updateSettings()
                    self.pieChartUpdate()
                    self.setupViews()
                    
                }))
                ac.addAction((UIAlertAction(title: "Ooops, I forgot.", style: .default, handler: { (action) in
                    print("No")
                })))
                
                present(ac, animated: true)
            case "showYes":
                dataHelper.addAndSaveHealthPoint(identifier: "Product")
                setupViews()
                print("Yes")
                
            case "showNo":
                // register answer
                print("No")
                
            default:
                break
            }
        }
        
        completionHandler()
    }

}

private extension LoggedInStartViewController {
    
    func getDataSet() -> PieChartDataSet {
        let stepsLeft = (7500 - stepsToday) > 0 ? (7500 - stepsToday) : 0
        
        if !toggleTitle {
            let entry1 = PieChartDataEntry(value: stepsToday , label: "Current steps")
            let entry3 = PieChartDataEntry(value: stepsLeft, label: "Steps to next healthpoint")
            
            return PieChartDataSet(values: [entry1, entry3], label: "")
            
        } else {
            
            let totalPoints = dataHelper.getTotalHealthPoints()
            let currentGoal = dataHelper.getCurrentGoal()
            let toNextLevel = currentGoal - totalPoints
            let entry1 = PieChartDataEntry(value: Double(totalPoints) , label: "Current points")
            let entry3 = PieChartDataEntry(value: Double(toNextLevel), label: "To next goal")
            
            return PieChartDataSet(values: [entry1, entry3], label: "")
        }
    }
    
    func pieChartUpdate() {
        let dataSet = getDataSet()
        dataSet.valueColors = [UIColor.black]
        dataSet.colors = [dataHelper.getChartColors().0, dataHelper.getChartColors().1]
        dataSet.drawValuesEnabled = false
        dataSet.valueFont = UIFont(name: "Futura", size: 20)!
        dataSet.valueColors = [Theme.current.textColor]
        
        let data = PieChartData(dataSets: [dataSet ] as [IChartDataSet])
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        data.setValueFormatter(DefaultValueFormatter(formatter: formatter))
        
        pieChart.data = data
        pieChart.legend.orientation = Legend.Orientation.vertical
        pieChart.chartDescription?.text = ""
        pieChart.holeColor = UIColor.clear
        pieChart.highlightPerTapEnabled = false
        pieChart.highlightValue(x: 0.0, dataSetIndex: 0)
        pieChart.drawEntryLabelsEnabled = false
        pieChart.legend.font = UIFont(name: "Futura", size: 16)!
        pieChart.legend.textColor = Theme.current.textColor
        pieChart.chartDescription?.font = UIFont(name: "Futura", size: 20)!
        pieChart.drawCenterTextEnabled = false
        pieChart.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOptionX: .easeInCirc, easingOptionY: .easeInCirc)
        let centerText = !toggleTitle ? NSMutableAttributedString(string: "Goal: 7500") : NSMutableAttributedString(string: "Goal: \(dataHelper.getCurrentGoal())")
        centerText.setAttributes([.font : UIFont(name: "Futura", size: 20)!, .foregroundColor: Theme.current.textColor ], range: NSRange(location: 0, length: centerText.length))
        pieChart.centerAttributedText = centerText
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            //            self.pieChart.drawEntryLabelsEnabled = true
            dataSet.drawValuesEnabled = true
            self.pieChart.drawCenterTextEnabled = true
            
        }
        pieChart.notifyDataSetChanged()
        
    }
    
    @objc func titleTapped() {
        if !toggleTitle {
            self.title = "Points"
            toggleButton.title = "Show steps"
            toggleTitle = true
            pieChartUpdate()
            
        } else {
            
            self.title = "Steps"
            toggleButton.title = "Show points"
            let stepsLeft = 7500 - stepsToday
            
            let entry1 = PieChartDataEntry(value: stepsToday , label: "Current steps")
            let entry3 = PieChartDataEntry(value: stepsLeft, label: "Steps to next healthpoint")
            
            
            dataSet = PieChartDataSet(values: [entry1, entry3], label: "")
            pieChart.notifyDataSetChanged()
            toggleTitle = false
            pieChartUpdate()
        }
        
    }
    
    @objc func showSettings() {
        performSegue(withIdentifier: "showSettings", sender: nil)
    }
    
    func setupViews() {
        let totalHealthPoints = dataHelper.getTotalHealthPoints()
        
        print("Current productHP: \(User.sharedInstance.productHealthPoints)")
        print("Current stepsHP: \(User.sharedInstance.stepHealthPoints)")
        print("Level: " + dataHelper.getCurrentLevel(totalHealthPoints))
        print("Current Total HP: \(dataHelper.getTotalHealthPoints())")
        print("Last product health point date: \(User.sharedInstance.lastProductHealthPoint.description)")
        print("Last product step point date: \(User.sharedInstance.lastStepHealthPoint.description)")
        pieChart.notifyDataSetChanged()
    }
    
    @IBAction func togglePieChart(_ sender: UIBarButtonItem) {
        titleTapped()
    }
}
