//
//  GameReviewTableViewCell.swift
//  CavyGame
//
//  Created by xuemincai on 15/8/18.
//  Copyright (c) 2015年 com.lvwenhan. All rights reserved.
//

import UIKit

class GameReviewTableViewCell: UITableViewCell {

    @IBOutlet weak var reviewBtn: DownloadButton!
    var delegate : GameReviewDelegate?
    @IBOutlet weak var titleLable: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLable.text = Common.LocalizedStringForKey("appinfo_title8")
        
        reviewBtn.setTitle(Common.LocalizedStringForKey("reviewBtn"), forState: UIControlState.allZeros)
        
        
        
        reviewBtn.initBnt()
        reviewBtn.setButtonImageStatus(DownBtnStatus_OC.STATUS_Down)
        
        
    }
    

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    @IBAction func OnclickReview(sender: UIButton) {
        
        delegate?.addReview()
        
    }
}

protocol GameReviewDelegate {
    
    func addReview()
    
}
