//
//  GameAppInfoTableViewCell.swift
//  CavyGame
//
//  Created by xuemincai on 15/8/18.
//  Copyright (c) 2015年 com.lvwenhan. All rights reserved.
//

import UIKit

class GameAppInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var developersLable: UILabel!
    @IBOutlet weak var gametypeLable: UILabel!
    @IBOutlet weak var updateTimeLable: UILabel!
    @IBOutlet weak var versionLable: UILabel!
    
    @IBOutlet weak var title1: UILabel!
    @IBOutlet weak var title2: UILabel!
    @IBOutlet weak var title3: UILabel!
    @IBOutlet weak var title4: UILabel!
    @IBOutlet weak var title5: UILabel!
    
    
    
    override func awakeFromNib() {
        
        title1.text = Common.LocalizedStringForKey("appinfo_title3")
        title2.text = Common.LocalizedStringForKey("appinfo_title4")
        title3.text = Common.LocalizedStringForKey("appinfo_title5")
        title4.text = Common.LocalizedStringForKey("appinfo_title6")
        
        println("title4.text = \(title4.text)")
        title5.text = Common.LocalizedStringForKey("appinfo_title7")
        
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
