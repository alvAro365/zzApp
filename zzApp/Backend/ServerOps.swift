//
//  ServerOps.swift
//  zzApp
//
//  Created by Alvar Aronija on 2018-09-21.
//  Copyright © 2018 Alvar Aronija. All rights reserved.
//

import UIKit
import SwiftDate

class ServerOps: NSObject {
    let SERVER_URL = "http://zzappprod.azurewebsites.net"
    let dataHelper = DataProvider()
    
    var onDataLoad: ((_ data: JSON) -> Void)?
    
    func loginWith(facebookID: String = "", customerID: String = "")  {
        let myDevice = UIDevice()
        let systemVersion = myDevice.systemVersion
        let systemName = myDevice.systemName
        let model = myDevice.model
        let loginType = facebookID != "" ? "loginfacebook" : "logincustomer"
        let loginID = facebookID != "" ? facebookID : customerID
        let key = facebookID != "" ? "zzUser_RegisterUser_FacebookIDResult" : "zzUser_RegisterUser_CustomerIDResult"
        
        print("Model: \(model), SystemName: \(systemName), Version: \(systemVersion)")
        let phoneModel = "Model-\(model), SystemName-\(systemName), Version-\(systemVersion)"
        let appVersion = getAppVersion()

        let requestUrl = "\(SERVER_URL)/zzappservice.svc/\(loginType)/\(loginID)/\(phoneModel)/\(appVersion)"
        let urlTextEscaped = requestUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let url = URL(string: urlTextEscaped!)
        print("URL:\(String(describing: url))")
        
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            guard let dataResponse = data,
                error == nil else {
                    print(error?.localizedDescription ?? "Response error")
                    return
            }
            guard let json = try? JSON(data: dataResponse) else {
                print("Json parsing failed")
                return
            }
//            print(json)
            
            let jsonDictionary = json[key]
            if let date = jsonDictionary["dAppRegDate"].stringValue.toDotNETDate(region: .current) {
                let dateWithFormat = date.toFormat("dd.MM.yyyy")
                User.sharedInstance.appRegDate = dateWithFormat
                print(User.sharedInstance.appRegDate)
            } else {
                print("Date not found")
            }
            
            let customerID = jsonDictionary["customerID"].stringValue
            let appID = jsonDictionary["iUserID"].intValue
            User.sharedInstance.customerID = customerID
            User.sharedInstance.appId = String(appID)
            print(User.sharedInstance.customerID)
            print(User.sharedInstance.appId)
//            completion(true)
            self.onDataLoad!(jsonDictionary)

        }
        task.resume()
    }
    
    func updateSettings() {
        let id = User.sharedInstance.appId
        let remindMeHour = "00"
        let remindMeMinute = "00"
        let numberOfHealthPoints = dataHelper.getTotalHealthPoints()
        let startProductDigit1 = "0"
        let startProductDigit2 = "0"
        let appVersion = getAppVersion()
        
        let requestUrl = "\(SERVER_URL)/zzappservice.svc/updatesettings_1_2/\(id)/\(remindMeHour)/\(remindMeMinute)/\(numberOfHealthPoints)/\(startProductDigit1)/\(startProductDigit2)/\(appVersion)"
        
        guard let urlTextEscaped = requestUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("Adding percentage encoding failed")
            return
        }
        guard let url = URL(string: urlTextEscaped) else {
            print("Createing url failed")
            return
        }
        print("URL:\(String(describing: url))")
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let dataResponse = data, error == nil else {
                print(error?.localizedDescription ?? "Response error")
                return
            }
            
            guard let json = try? JSON(data: dataResponse) else {
                print("Json parsing failed")
                return
            }
            print("Printing json")
            print(json)
            
            let result = json["zzUser_Updatedetails_V1_2Result"]
            
            let status = result["sStatus"].boolValue
            let numberOfHealthPoints = result["numberOfdays"].intValue

            self.onDataLoad?(result)
            print("Status: \(status), HealthPoints: \(numberOfHealthPoints) " )
            
        }
        
        task.resume()
    }
    
    func startBalanceTest() {
        let age = String(User.sharedInstance.age)
        let country = User.sharedInstance.country
        let email = User.sharedInstance.email
        let name = User.sharedInstance.name
        let sex = User.sharedInstance.sex
        let startBalanceDigit1 = "15"
        let startBalanceDigit2 = "1"
//        let remindHour = "09"
        let remindHour = User.sharedInstance.dailyReminder.components(separatedBy: ":")[0]
        let remindMinute = User.sharedInstance.dailyReminder.components(separatedBy: ":")[1]
        let userId = User.sharedInstance.appId
        let startDate = User.sharedInstance.startDate

        let requestUrl = "\(SERVER_URL)/zzappservice.svc/zzUser_StartTest_V1_1/\(userId)/\(sex)/\(age)/\(country)/\(name)/\(email)/\(remindHour)/\(remindMinute)/\(startDate)/\(startBalanceDigit1)/\(startBalanceDigit2)"
        
        print(requestUrl)
        
        guard let urlTextEscaped = requestUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("Adding percentage encoding failed")
            return
        }
//        http://zzappprod.azurewebsites.net/zzappservice.svc/zzUser_StartTest_V1_1/17303/Male/30/Sweden/Test/test@example.com/09/00/04.04.2014/15/1

        guard let url = URL(string: urlTextEscaped) else {
            print("Createing url failed")
            return
        }
        print("Start test:")
        print(url)
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let dataResponse = data, error == nil else {
                print(error?.localizedDescription ?? "Response error")
                return
            }
            print("Dataresponse:")
            print(dataResponse)
            
            guard let json = try? JSON(data: dataResponse) else {
                print("Json parsing failed")
                return
            }
            print("Printing json")
            print(json)
            
            let result = json["zzUser_StartTest_V1_1Result"]
            let numberOfHealthPoints = result["iNumberOfDays"].intValue
            
            User.sharedInstance.stepHealthPoints = numberOfHealthPoints
            
            print("Number of health points received: \(numberOfHealthPoints)")
            
            self.onDataLoad?(result)
        }
        
        task.resume()
        
    }

    func getAppVersion() -> String {
        return "iOS 1.3"
    }
    
}
