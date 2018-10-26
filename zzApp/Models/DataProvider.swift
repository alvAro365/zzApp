//
//  DataProvider.swift
//  zzApp
//
//  Created by Alvar Aronija on 2018-09-11.
//  Copyright © 2018 Alvar Aronija. All rights reserved.
//

import Foundation
import SwiftDate

class DataProvider {
    let defaults = UserDefaults.standard
    let piePieceColors = [UIColor(hexString: "#FFD960"), UIColor(hexString: "67A3CC"), UIColor(hexString: "#D4665E"), UIColor(hexString: "6E4D97")]

    func getCurrentLevel(_ currentNoOfHealthPoints: Int) -> String {
        switch self.getTotalHealthPoints().compare() {
        case .silver:
            return "Beginner"
        case .freshman:
            return "Freshman"
        case .progressive:
            return "Progressive"
        case .advanced:
            return "Advanced"
        case .master:
            return "Master"
        }
    }

    func getTotalHealthPoints() -> Int {
        return User.sharedInstance.stepHealthPoints + User.sharedInstance.productHealthPoints
    }
    
    func getCurrentGoal() -> Int {
        switch self.getTotalHealthPoints().compare() {
        case .silver:
            return 120
        case .freshman:
            return 360
        case .progressive:
            return 720
        case .advanced:
            return 1800
        default:
            return 3600
        }
    }
    
    func getChartColors() -> (UIColor, UIColor) {
        switch self.getTotalHealthPoints().compare() {
            case .silver:
                return (UIColor.green, piePieceColors[0])
            case .freshman:
                return (piePieceColors[0], piePieceColors[1])
            case .progressive:
                return (piePieceColors[1], piePieceColors[2])
            case .advanced:
                return (piePieceColors[2], piePieceColors[3])
            case .master:
                return (piePieceColors[3], UIColor.black)
        }
    }

    func saveUser(_ user: User) {
        let jsonEncoder = JSONEncoder()
        if let savedUser = try? jsonEncoder.encode(user) {
            defaults.set(savedUser, forKey: "user")
            print("User saved")
        } else {
            print("Failed to save the user.")
        }
    }
    
    func getDefaultUser() -> User? {
        let user: User
        if let savedUser = defaults.object(forKey: "user") as? Data {
            let jsonDecoder = JSONDecoder()
            
            do {
                user = try jsonDecoder.decode(User.self, from: savedUser)
                return user
            } catch {
                print("Failed to load the user")
            }
        }
        
        return nil
    }
    
    
    func addAndSaveHealthPoint(identifier: String) {
       
        switch identifier {
        case "Step":
            // add step point
            if !User.sharedInstance.lastStepHealthPoint.isToday {
                User.sharedInstance.stepHealthPoints += 1
                User.sharedInstance.lastStepHealthPoint = Date()
            } else {
                print("User has already received a step point today")
                return
            }
        case "Product":
            // add product point
            if !User.sharedInstance.lastProductHealthPoint.isToday {
                User.sharedInstance.productHealthPoints += 1
                User.sharedInstance.lastProductHealthPoint = Date()
            } else {
                print("User has already received a product health point today")
                return
            }
        default:
            fatalError("Unknown identifier")
        }
        saveUser(User.sharedInstance)
    }
    
    func saveDailyReminder(hourAndMinutes: String) {
        User.sharedInstance.dailyReminder = hourAndMinutes
        saveUser(User.sharedInstance)
    }
    
    func eligableForPoint(previousPoint: Date) -> Bool {
        return previousPoint.isToday
    }
}
