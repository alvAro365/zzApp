//
//  String+CountryCode+Sex.swift
//  zzApp
//
//  Created by Alvar Aronija on 2018-10-08.
//  Copyright © 2018 Alvar Aronija. All rights reserved.
//

import Foundation

extension String {
    
    enum Country: String {
        case sweden = "46"
        case norway = "47"
        case finland = "351"
        case denmark = "45"
        case faroeIslands = "298"
        case iceland = "354"
        case estonia = "372"
        case latvia = "371"
        case lithuania = "370"
        case spain = "34"
        
    }
    
    enum Sex: String {
        case male = "2"
        case female = "1"
        case other = "3"
    }
    
    func sex() -> Sex {
        switch self {
        case "Male":
            return .male
        case "Other":
            return .other
        case "Female":
            return .female
        default:
            return .female
        }
    }
    
    func code() -> Country {

        switch self {
        case "Norway":
            return .norway
        case "Sweden":
            return .sweden
        case "Finland":
            return .finland
        case "Denmark":
            return .denmark
        case "Iceland":
            return .iceland
        case "Estonia":
            return .estonia
        case "Latvia":
            return .latvia
        case "Lithuania":
            return .lithuania
        case "Spain":
            return .spain
        default:
            return .sweden
        }
    }
}
