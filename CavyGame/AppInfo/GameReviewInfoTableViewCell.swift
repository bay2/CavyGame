//
//  GameReviewInfoTableViewCell.swift
//  CavyGame
//
//  Created by xuemincai on 15/8/19.
//  Copyright (c) 2015年 com.lvwenhan. All rights reserved.
//

import UIKit

class GameReviewInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var contentLable: UILabel!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var datetimeLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var imageLine: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    /**
    设置评论
    
    :param: text 评论信息
    */
    func setContentText(text : NSString) {
        
        contentLable.text = text as String
        
        var txtSize : CGSize = CGSize(width: imageLine.frame.width, height: 130)
            
        var attributedString : NSMutableAttributedString = NSMutableAttributedString(string: text as String)
            
        var paragraphStyle : NSMutableParagraphStyle = NSMutableParagraphStyle()
            
        paragraphStyle.lineSpacing = 1
        
        attributedString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, text.length))
            
        contentLable.attributedText = attributedString
                    
        contentLable.sizeToFit()
    
    }
    
}
