//
//  User.swift
//  zzApp
//
//  Created by Alvar Aronija on 2018-09-11.
//  Copyright © 2018 Alvar Aronija. All rights reserved.
//

import Foundation
import SwiftDate

class User: NSObject, Codable {
    static var sharedInstance: User = {
        if let defaultUser = UserDefaults.standard.object(forKey: "user") as? Data {
            let jsonDecoder = JSONDecoder()
            do {
                return try jsonDecoder.decode(User.self, from: defaultUser)
            } catch {
                print("Failed to load the user")
            }
        }
        return User()
    }()

    var age: Int = 0
    var appId: String = ""
    var appRegDate: String = ""
    var customerID: String = ""
    var country: String = ""
    var dailyReminder: String = "09:00"
    var email: String = ""
    var id: String = ""
    var lastProductHealthPoint: Date = Date() - 2.days
    var lastStepHealthPoint: Date = Date() - 2.days
    var name: String = ""
    var productHealthPoints: Int = 0
    var sex: String = ""
    var stepHealthPoints: Int = 0
    var startDate: String = ""
    var user: User?

    private override init() {}

}
