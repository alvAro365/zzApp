//
//  GoalsTableViewCell.swift
//  zzApp
//
//  Created by Alvar Aronija on 2018-09-19.
//  Copyright © 2018 Alvar Aronija. All rights reserved.
//

import UIKit

class GoalsTableViewCell: UITableViewCell {
    @IBOutlet weak var achievementLabel: UILabel!
    @IBOutlet weak var goalLabel: UILabel!
    @IBOutlet weak var rewardLabel: UILabel!
    @IBOutlet weak var rewardDescription: UILabel!
    @IBOutlet weak var lock: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
