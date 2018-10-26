//
//  LocalNotification.swift
//  zzApp
//
//  Created by Alvar Aronija on 2018-09-13.
//  Copyright © 2018 Alvar Aronija. All rights reserved.
//

import Foundation
import UserNotifications

class LocalNotification {
    
    func scheduleLocal(hour: Int, minute: Int) {
        registerCategories()
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.body = "Did you take your Balance product today?"
        content.categoryIdentifier = "alarm"
        content.userInfo = ["customData": "fizzbuzz"]
        content.sound = UNNotificationSound.default()
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
    }
    
    func registerCategories() {
        let center = UNUserNotificationCenter.current()
        let showYes = UNNotificationAction(identifier: "showYes", title: "Yes, Of course.")
        let showNo = UNNotificationAction(identifier: "showNo", title: "No, I forgot.")
        let category = UNNotificationCategory(identifier: "alarm", actions: [showYes, showNo], intentIdentifiers: [])
        
        center.setNotificationCategories([category])
    }
}
