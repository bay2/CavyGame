//
//  SetTableViewCell.swift
//  CavyGame
//
//  Created by xuemincai on 15/9/1.
//  Copyright (c) 2015年 com.lvwenhan. All rights reserved.
//

import UIKit

class SetTableViewCell: UITableViewCell {

    @IBOutlet weak var bottomLine: UIImageView!
    @IBOutlet weak var setInfoLabel: UILabel!
    @IBOutlet weak var setSwitch: UISwitch!
    @IBOutlet weak var setTitleLabel: UILabel!
    var switchDelegate : SwitchDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    @IBAction func onSwitch(sender: UISwitch) {
        
        switchDelegate?.switchChange(sender)
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

protocol SwitchDelegate {
    
    func switchChange(sender: UISwitch)
    
}
