//
//  PrefectureDownloadWithProgressButton.swift
//  CavyGame
//
//  Created by xuemincai on 15/9/5.
//  Copyright (c) 2015年 com.lvwenhan. All rights reserved.
//

import UIKit

class PrefectureDownloadWithProgressButton: DownloadWithProgressButton {
    
    var style : Dictionary<String, AnyObject>? {
        
        didSet {
            
            setButtonImageStatus(DownBtnStatus_OC.STATUS_Down)
            
        }
        
    }
    
    override func setButtonImageStatus(status : Int) {
        
        
        super.setButtonImageStatus(status)
        
        if nil == self.style {
            
            return
            
        }
        
        var color = style!["color"] as! Dictionary<String, AnyObject>
        var btnStyle : Dictionary<String, AnyObject>?

        //根据不同状态获取按钮style
        switch (status) {
            case DownBtnStatus_OC.STATUS_Down:
                btnStyle = color["download_button"] as? Dictionary<String, AnyObject>
            
            case DownBtnStatus_OC.STATUS_Pause:
                btnStyle = color["pause_button"] as? Dictionary<String, AnyObject>
            
            case DownBtnStatus_OC.STATUS_Finish:
                btnStyle = color["open_button"] as? Dictionary<String, AnyObject>

            default:
                break
        }
        
        
        //设置Highlighted按钮style
        setButtonStyle(btnStyle, state: UIControlState.Highlighted)

        //设置Normal按钮style
        setButtonStyle(btnStyle, state: UIControlState.Normal)
        
        
    }
    
    /**
    设置按钮风格
    
    :param: btnStyle 风格
    :param: state    按钮状态
    */
    func setButtonStyle(btnStyle : Dictionary<String, AnyObject>?, state: UIControlState) {
        
        var stateString = "normal"
        
        if state == UIControlState.Highlighted {
            
            stateString = "highlight"
        }
        
        if let normalStyle = btnStyle?[stateString] as? Dictionary<String, AnyObject> {
            
            let borderColorString = normalStyle["border"] as! String
            var borderColor = ((borderColorString == "clearColor") ? UIColor.clearColor() :  UIColor(hexString: borderColorString))
            
            let backgroundColorString = normalStyle["background"] as! String
            var backgroundColor = ((backgroundColorString == "clearColor") ? UIColor.clearColor() :  UIColor(hexString: backgroundColorString))
            
            let textColorString = normalStyle["text"] as! String
            var textColor = ((textColorString == "clearColor") ? UIColor.clearColor() :  UIColor(hexString: textColorString))
                            
            self.layer.borderColor = borderColor!.CGColor
            self.setBackgroundCoclor(backgroundColor, forState: state)
            self.setTitleColor(textColor, forState: state)
            downPress.textColor = textColor
            
        }
        
    }

}
