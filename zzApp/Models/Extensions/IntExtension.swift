//
//  IntExtensions.swift
//  zzApp
//
//  Created by Alvar Aronija on 2018-09-12.
//  Copyright © 2018 Alvar Aronija. All rights reserved.
//

import Foundation

extension Int {
    enum ComparisonOutcome {
        case silver
        case freshman
        case progressive
        case advanced
        case master
    }
    
    func compare() -> ComparisonOutcome {
        if self < 120 {
            return .silver
        } else if (self >= 120 && self < 360) {
            return .freshman
        } else if (self >= 360 && self < 720) {
            return .progressive
        } else if (self >= 720 && self < 1800) {
            return .advanced
        } else if self >= 1800  {
            return .master
        }
        
        return .freshman
    }
}

