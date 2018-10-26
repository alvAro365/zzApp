//
//  Theme.swift
//  zzApp
//
//  Created by Alvar Aronija on 2018-10-09.
//  Copyright © 2018 Alvar Aronija. All rights reserved.
//

import Foundation
import UIKit

enum Theme: Int {
    case light, dark
    
    private enum Keys {
        static let selectedTheme = "SelectedTheme"
    }
    
    static var current: Theme {
        let storedTheme = UserDefaults.standard.integer(forKey: Keys.selectedTheme)
        return Theme(rawValue: storedTheme) ?? .dark
    }
    
    var mainColor: UIColor {
        switch self {
        case .light:
            return UIColor(hexString: "#440099")
//            return UIColor(hexString: "#9DC418")
        case .dark:
            return UIColor(hexString: "#9DC418")
//            return UIColor(hexString: "#440099")
        }
    }
    
    var thumbTintColor: UIColor {
        switch self {
        case .light:
//            return UIColor(hexString: "#9DC418")
            return UIColor(hexString: "#440099")
        case .dark:
            return .white
        }
    }
    
    var barStyle: UIBarStyle {
        switch self {
        case .light:
            return .default
        case .dark:
            return .black
        }
    }
    
    var backgroundColor: UIColor {
        switch self {
        case .light:
            return .white
        case .dark:
            return .black
        }
    }
    
    var textColor: UIColor {
        switch self {
        case .light:
            return .black
        case .dark:
            return .white
        }
    }

    func apply() {
        UIView.appearance(whenContainedInInstancesOf: [SettingsViewController.self]).backgroundColor = backgroundColor
        UserDefaults.standard.set(rawValue, forKey: Keys.selectedTheme)
        UserDefaults.standard.synchronize()

        UIApplication.shared.delegate?.window??.tintColor = mainColor
        
        UINavigationBar.appearance().barStyle = barStyle
        UITabBar.appearance().barStyle = barStyle

        UIView.appearance(whenContainedInInstancesOf: [LoggedInStartViewController.self]).backgroundColor = backgroundColor
        UIView.appearance(whenContainedInInstancesOf: [GoalsTableViewController.self]).backgroundColor = backgroundColor
        UIView.appearance(whenContainedInInstancesOf: [ProductsTableViewController.self]).backgroundColor = backgroundColor
        UIView.appearance(whenContainedInInstancesOf: [SignInViewController.self]).backgroundColor = backgroundColor

        UIView.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).tintColor = mainColor
        UILabel.appearance(whenContainedInInstancesOf: [UITableViewCell.self]).textColor = textColor
        UIImageView.appearance(whenContainedInInstancesOf: [GoalsTableViewController.self]).backgroundColor = .clear
        UITextView.appearance(whenContainedInInstancesOf: [UITableViewCell.self]).textColor = textColor
        UITextView.appearance(whenContainedInInstancesOf: [UITableViewCell.self]).textColor = textColor
        
        UISwitch.appearance(whenContainedInInstancesOf: [UIView.self, ThemeTableViewCell.self, SettingsViewController.self]).thumbTintColor = thumbTintColor
        UISwitch.appearance(whenContainedInInstancesOf: [ThemeTableViewCell.self, SettingsViewController.self]).onTintColor = mainColor
        
        UIView.appearance(whenContainedInInstancesOf: [ThemeTableViewCell.self, SettingsViewController.self]).backgroundColor = .clear
        UIView.appearance(whenContainedInInstancesOf: [UITableViewCell.self, SettingsViewController.self]).backgroundColor = .clear
        UIView.appearance(whenContainedInInstancesOf: [UITableView.self, SettingsViewController.self]).backgroundColor = .clear

    }
}
