//
//  GameTitleTableViewCell.swift
//  CavyGame
//
//  Created by xuemincai on 15/8/18.
//  Copyright (c) 2015年 com.lvwenhan. All rights reserved.
//

import UIKit

class GameTitleTableViewCell: UITableViewCell {

    @IBOutlet weak var titleImage: UIImageView!
    @IBOutlet weak var titleGameName: UILabel!
    @IBOutlet weak var titleGameInfo: UILabel!
    @IBOutlet weak var titleGameSize: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setGameInfo(text : NSString) {
        
        titleGameInfo.text = text as String
        
        if .UIDeviceResolution_iPhoneRetina4 == resolution() {
            
            return
        }
        
        var attributedString : NSMutableAttributedString = NSMutableAttributedString(string: text as String)
        
        var paragraphStyle : NSMutableParagraphStyle = NSMutableParagraphStyle()
        
        paragraphStyle.lineSpacing = 3
        
        attributedString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, text.length))
        
        titleGameInfo.attributedText = attributedString

        
    }
    
}
