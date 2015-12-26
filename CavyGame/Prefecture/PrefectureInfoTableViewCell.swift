//
//  PrefectureInfoTableViewCell.swift
//  CavyGame
//
//  Created by xuemincai on 15/9/6.
//  Copyright (c) 2015年 com.lvwenhan. All rights reserved.
//

import UIKit

class PrefectureInfoTableViewCell: UITableViewCell {


    @IBOutlet weak var prefectureInfo: UILabel!
    @IBOutlet weak var halvingline: UIImageView!
    @IBOutlet weak var prefectureTitle: UILabel!
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
    func setPrefectureInfoText(text : NSString) {
        
        prefectureInfo.text = text as String
        
        var txtSize : CGSize = CGSize(width: self.frame.width, height: CGFloat(MAXFLOAT))
        
        var attributedString : NSMutableAttributedString = NSMutableAttributedString(string: text as String)
        
        var paragraphStyle : NSMutableParagraphStyle = NSMutableParagraphStyle()
        
        paragraphStyle.lineSpacing = 5
        paragraphStyle.alignment = NSTextAlignment.Justified
        
        attributedString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, text.length))
        
        prefectureInfo.attributedText = attributedString
        
        txtSize = text.textSizeWithFont(prefectureInfo.font, constrainedToSize: CGSize(width: txtSize.width, height: CGFloat(MAXFLOAT)))
        
        prefectureInfo.sizeToFit()
        
    }

}
