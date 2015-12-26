//
//  GameInfoTableViewCell.swift
//  CavyGame
//
//  Created by longjining on 15/8/11.
//  Copyright (c) 2015年 com.lvwenhan. All rights reserved.
//

import UIKit

class GameInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var sizeAndDownCnt: UILabel!
    @IBOutlet weak var detail: UILabel!
    @IBOutlet weak var down: PrefectureDownloadWithProgressButton!
    @IBOutlet weak var halvingline: UIImageView!

    var norBkColor : UIColor!         // 常态下背景颜色
    var highlightedBkColor : UIColor! // 点击颜色
    
    var itemInfo : GameSubInfo!{
        didSet{
            down.itemInfo = itemInfo
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.down.setButtonImageStatus(DownBtnStatus_OC.STATUS_Down)
        self.down.initBnt()
        
        icon.image = UIImage(named: "icon_game")
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
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func onClickDown(sender : AnyObject){
        
        down.clickDownBtn();
    }
}