//
//  GameInfoImgTableViewCell.swift
//  CavyGame
//  专题cell
//  Created by longjining on 15/8/26.
//  Copyright (c) 2015年 com.lvwenhan. All rights reserved.
//

import UIKit

class GameInfoImgTableViewCell: UITableViewCell {

    @IBOutlet weak var specialTopicBtn: UIButton!  // 专题图片

    var prefectureInfo : PrefectureSubInfo!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // 设置圆角
        
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func onClickBtn(sender : UIButton){
        
        if prefectureInfo == nil{
            return
        }
        
        showPrefecture(prefectureInfo.prefectureId!, prefectureStyle : prefectureInfo.style!)
    }
    
    func showPrefecture(prefectureID : Int, prefectureStyle : String){
        
        // 显示专题
        
        var preListVc : PrefecturListViewController!
        
        switch resolution() {
            
        case .UIDeviceResolution_iPhoneRetina4:
            preListVc = UIStoryboard(name: "Prefecture_iPhone4", bundle: nil).instantiateViewControllerWithIdentifier("PrefectureListView") as! PrefecturListViewController
            
        case .UIDeviceResolution_iPadRetina:
            preListVc = UIStoryboard(name: "Prefecture_iPadRetina", bundle: nil).instantiateViewControllerWithIdentifier("PrefectureListView") as! PrefecturListViewController
            
        case .UIDeviceResolution_iPadStandard:
            preListVc = UIStoryboard(name: "Prefecture_iPadRetina", bundle: nil).instantiateViewControllerWithIdentifier("PrefectureListView") as! PrefecturListViewController
            
        default:
            preListVc = Common.getViewControllerWithIdentifier("Prefecture", identifier: "PrefectureListView") as! PrefecturListViewController
            
        }
        
        preListVc.preId = prefectureID
        preListVc.styleType = prefectureStyle
        
        Common.rootViewController.homeViewController.navigationController?.pushViewController(preListVc, animated: true)

    }
}
