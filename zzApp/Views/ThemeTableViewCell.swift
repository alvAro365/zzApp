//
//  ThemeTableViewCell.swift
//  zzApp
//
//  Created by Alvar Aronija on 2018-10-17.
//  Copyright © 2018 Alvar Aronija. All rights reserved.
//

import UIKit

class ThemeTableViewCell: UITableViewCell {
    @IBOutlet weak var theme: UILabel!
    @IBOutlet weak var themeSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
}
