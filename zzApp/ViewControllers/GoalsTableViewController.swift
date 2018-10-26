//
//  GoalsTableViewController.swift
//  zzApp
//
//  Created by Alvar Aronija on 2018-09-19.
//  Copyright © 2018 Alvar Aronija. All rights reserved.
//

import UIKit

class GoalsTableViewController: UITableViewController {
    
    // MARK: - Properties
    let achievements = AchievementsHelper().achievements
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// MARK: - UITableViewDatasource

extension GoalsTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return achievements.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AchievementCell", for: indexPath) as! GoalsTableViewCell
        let keys = Array(achievements.keys).sorted { $0 < $1 }
        
        
        cell.achievementLabel.text = achievements[keys[indexPath.row]]!["title"]?.uppercased()
        let hexString = achievements[keys[indexPath.row]]!["color"]
        cell.achievementLabel.backgroundColor = UIColor(hexString: hexString!)
        let totalPoints = User.sharedInstance.productHealthPoints + User.sharedInstance.stepHealthPoints
        var showIndex = -1
        
        switch totalPoints.compare() {
        case .freshman:
            showIndex = 0
        case .progressive:
            showIndex = 1
        case .advanced:
            showIndex = 2
        case .master:
            showIndex = 3
        default:
            showIndex = -1
        }
        
        indexPath.row <= showIndex ? (cell.contentView.alpha = 1.0) : (cell.contentView.alpha = 0.25)
        indexPath.row <= showIndex ? (cell.lock.image = #imageLiteral(resourceName: "unlocked") ): (cell.lock.image = #imageLiteral(resourceName: "lock"))

        cell.goalLabel.text = achievements[keys[indexPath.row]]!["goal"]?.uppercased()
        cell.rewardDescription.text = achievements[keys[indexPath.row]]!["reward"]?.uppercased()
        
        return cell
    }
}
