//
//  NoticeTableViewCell.swift
//  CavyGame
//
//  Created by xuemincai on 15/7/27.
//  Copyright (c) 2015年 com.lvwenhan. All rights reserved.
//

import UIKit

class NoticeTableViewCell: UITableViewCell {

    @IBOutlet weak var noticeIcon: UIImageView!
    @IBOutlet weak internal var titleLable: UILabel!
    @IBOutlet weak internal var contentLable: UILabel!
    @IBOutlet weak var createTimeLable: UILabel!
    var norBkColor : UIColor!         // 常态下背景颜色
    var highlightedBkColor : UIColor! // 点击颜色
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }


    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func setHighlighted(highlighted: Bool, animated: Bool){
        super.setHighlighted(selected, animated: animated)
        
        if highlighted{
            if highlightedBkColor != nil{
                self.backgroundColor = highlightedBkColor
            }else{
                self.backgroundColor = Common.cellSetHighlightedBkColor
            }
        }else{
            if norBkColor != nil{
                self.backgroundColor = self.norBkColor
            }else{
                self.backgroundColor = UIColor.whiteColor()
            }
        }
    }
    
}
