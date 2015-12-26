//
//  UpdateInfoTableViewCell.swift
//  CavyGame
//
//  Created by xuemincai on 15/12/25.
//  Copyright © 2015年 com.lvwenhan. All rights reserved.
//

import UIKit

class UpdateInfoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var updateTimeLab: UILabel!
    @IBOutlet weak var updateInfoLab: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    /**
    设置更新信息
    
    - parameter updateTime: 更新时间
    - parameter situation:  更新公告
    */
    func setUpdateInfo(updateTime: String, situation: String) {
        
        updateTimeLab.text = updateTime
        updateInfoLab.text = situation
        
        var attributedString : NSMutableAttributedString = NSMutableAttributedString(string: situation)
        
        var paragraphStyle : NSMutableParagraphStyle = NSMutableParagraphStyle()
        
        paragraphStyle.lineSpacing = 6
        
        attributedString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, (situation as NSString).length))
        
        updateInfoLab.attributedText = attributedString
        
        
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        
        var totalHeight : CGFloat = 0
        totalHeight += updateInfoLab.sizeThatFits(size).height
        totalHeight += updateTimeLab.sizeThatFits(size).height
        totalHeight += 66
        
        return CGSizeMake(size.width, totalHeight)
    }
    
}
