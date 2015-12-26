//
//  GameRecommendTableViewCell.swift
//  CavyGame
//
//  Created by xuemincai on 15/8/18.
//  Copyright (c) 2015年 com.lvwenhan. All rights reserved.
//

import UIKit

class GameRecommendTableViewCell: UITableViewCell {

    @IBOutlet weak var gameRecommendLable: UILabel!
    
    
    @IBOutlet weak var titlelabel: UILabel!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        titlelabel.text = Common.LocalizedStringForKey("appinfo_title1")
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    /**
    设置简介信息
    
    :param: text 简介信息
    */
    func setGameRecommendText(text : NSString) {
        
        gameRecommendLable.text = text as String
        var txtSize : CGSize = CGSize(width: self.frame.width - 24, height: 130)
        
        var attributedString : NSMutableAttributedString = NSMutableAttributedString(string: text as String)
        
        var paragraphStyle : NSMutableParagraphStyle = NSMutableParagraphStyle()
        
        paragraphStyle.lineSpacing = 6
        
        attributedString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, text.length))
        
        gameRecommendLable.attributedText = attributedString
        
        gameRecommendLable.sizeToFit()

    }
    
}
