//
//  PrefectureTableViewCell.swift
//  CavyGame
//
//  Created by xuemincai on 15/9/3.
//  Copyright (c) 2015年 com.lvwenhan. All rights reserved.
//

import UIKit

class PrefectureTableViewCell: UITableViewCell {

    var preDelegate : PrefectureDelegate?

    @IBOutlet weak var prefectureBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "nofityShowLeftView:", name: Common.notifyShowLeftView, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "nofityShowHomeView:", name: Common.notifyShowHomeView, object: nil)
    }
    
    func nofityShowHomeView(notification:NSNotification){
        
        prefectureBtn.enabled = true
    }
    
    func nofityShowLeftView(notification:NSNotification){
        
        prefectureBtn.enabled = false
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }


    @IBAction func onClickPrefecture(sender: UIButton) {
        
        preDelegate?.onClickPre(sender)
        
    }
}

protocol PrefectureDelegate {
    
    func onClickPre(sender: UIButton)
    
}
