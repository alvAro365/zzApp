//
//  HealthKitHelper.swift
//  zzApp
//
//  Created by Alvar Aronija on 2018-09-07.
//  Copyright © 2018 Alvar Aronija. All rights reserved.
//

import Foundation
import HealthKit
import SwiftDate

protocol HealthKitDelegate: class {
    func didReceiveDataUpdate(data: Double)
}

class HealthKit {
    weak var delegate: HealthKitDelegate?
    let dataHelper = DataProvider()
    let serverOps = ServerOps()
    let healthStore: HKHealthStore? = {
        if HKHealthStore.isHealthDataAvailable() {
            return HKHealthStore()
        } else {
            return nil
        }
    }()
    
    init() {
        checkAuthorization()
    }
    
    func getDailySteps() {
        print("Getting daily steps")
        let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: stepsQuantityType!, quantitySamplePredicate: predicate, options: .cumulativeSum) { (_, result, error) in
            guard let result = result, let sum = result.sumQuantity() else {
                print(error!)
                return
            }
            let steps = sum.doubleValue(for: HKUnit.count())
            print("Steps: " + String(steps))

            if steps >= 1500 && !(User.sharedInstance.lastStepHealthPoint.compare(.isToday)){
                print("Qualified for step health point")
                self.dataHelper.addAndSaveHealthPoint(identifier: "Step")
                self.serverOps.updateSettings()
                
            } else {
                print("1 Step point per day limit")
            }

            DispatchQueue.main.async {
                self.delegate?.didReceiveDataUpdate(data: steps)
            }
        }
        healthStore?.execute(query)
    }
    
    private func checkAuthorization() {
        if (healthStore != nil) {
            print("Health data is available")
            let allTypes = Set([HKObjectType.quantityType(forIdentifier: .stepCount)!])
            healthStore?.requestAuthorization(toShare: nil, read: allTypes) { (success, error) in
                if !success {
                    print("Error while requesting authorization: ")
                    print(error!)
                } else {
                    print("Permission to read health data granted")
                }
            }
        }
    }
}
