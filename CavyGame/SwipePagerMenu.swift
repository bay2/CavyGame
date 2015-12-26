//
//  SwipePagerMenu.swift
//  表头切换按钮
//
//  Created by longjining on 15/8/8.
//  Copyright (c) 2015年 com.lvwenhan. All rights reserved.
//

import UIKit

protocol SwipePagerMenuDelegate {
    func swipePagerMenu(sender: UIButton)
}

class SwipePagerMenu: UIView {
    
    static var menuTotalHight : CGFloat {
        
        get {
            
            if .UIDeviceResolution_iPhoneRetina4 == resolution() {
                
                return 41.5
                
            } else {
                
                return 49 // tab的总体高度 48 ＋ 1
            }
            
        }
        
    }
    
    //let btnHight : CGFloat = 46.5
    
    var btnHight : CGFloat {
        
        get {
            
            if .UIDeviceResolution_iPhoneRetina4 == resolution() {
                
                return 40.5
                
            } else {
                
                return 46.5
            }
            
        }
        
    }
    
    let imgViewHigth : CGFloat = 1.5             // 当前下滑线高度
    
    let spaceLightHigth : CGFloat = 1           // 分割线高度
    let spaceLightColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.15) // 分割线颜色
    
    let btnNomalColor = UIColor(hexString: "414141")
    let btnHightColor = Common.TitleBarColor
    
    var btnWidth : CGFloat = 0.0;
    var btns = [UIButton]()
    var imgV : UIImageView!
    
    var delegate : SwipePagerMenuDelegate? = nil
    
    init(arrTitle : [NSString], frame: CGRect){
        
        super.init(frame: frame);
        
        var btnNum = Float(arrTitle.count);
        var frameWidth = Float(frame.width);
        btnWidth = CGFloat(frameWidth / btnNum)
        
        // scrollview
        var scrollViewFrame : CGRect = frame
        scrollViewFrame.size.height -= spaceLightHigth
        
        var scrollView = UIScrollView(frame: scrollViewFrame)
        scrollView.bounces = false  // 禁止滑动出边境
        
        var btnX : CGFloat = 0.0
        var iIndex = 0
        
        // 添加按钮
       for title in arrTitle{
            var btnFrame = CGRectMake(CGFloat(Float(iIndex) * Float(btnWidth)), 0.0, btnWidth, btnHight)
            var btn = UIButton(frame: btnFrame)
        
        
            if .UIDeviceResolution_iPhoneRetina4 == resolution() {
                
                btn.titleLabel!.font = UIFont.systemFontOfSize(16)
                
            }
        
          if Common.getPreferredLanguage() == "en"{
            switch resolution() {
                // 为了显示 Recommmend
            case .UIDeviceResolution_iPhoneRetina4 :
                btn.titleLabel!.font = UIFont.systemFontOfSize(12)
                break
                
            default:
                btn.titleLabel!.font = UIFont.systemFontOfSize(14)

                break
                
            }
          }
       
        
            btn.setTitle(title as String, forState: UIControlState.Normal)
            btn.setTitleColor(btnNomalColor, forState: UIControlState.Normal)
            btn.setTitleColor(btnHightColor, forState: UIControlState.Selected)

            btn.tag = iIndex++
        
            btn.addTarget(self, action: Selector("onClickBtn:"), forControlEvents: UIControlEvents.TouchUpInside)
            btns.append(btn)
        
            scrollView.addSubview(btn)
        }
        btns[0].selected = true
        // 按钮下滑线
        var imgFrame = CGRectMake(0.0, frame.height - imgViewHigth - spaceLightHigth, CGFloat(btnWidth), imgViewHigth)
        imgV = UIImageView(frame: imgFrame)
        imgV.backgroundColor = btnHightColor
        scrollView.addSubview(imgV);
        var spaceImgV : UIImageView
        
        // ios7.0 无法加载.9图片
        spaceImgV = UIImageView(frame: CGRectMake(0.0,frame.height - spaceLightHigth, frame.width, spaceLightHigth))
        spaceImgV.image = UIImage()
        spaceImgV.backgroundColor = UIColor(hexString: "#dedede")
       
        self.addSubview(spaceImgV)
        
        self.addSubview(scrollView)
        
        self.backgroundColor = UIColor.whiteColor()
    }

    func enableBtn(enable : Bool){
        
        for (var i = 0; i < btns.count; i++){
            btns[i].enabled = enable
        }
    }
    
    func onClickBtn(sender : UIButton){
        
        self.delegate?.swipePagerMenu(sender)
        
        pageChange(sender.tag)
    }
    
    func pageChange(var curPage : Int){
        
        if curPage >= self.btns.count {
            curPage = self.btns.count - 1
        }
        
        var frame = self.imgV.frame;
        
        frame.origin.x = CGFloat(Float(curPage) * Float(btnWidth));
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.2)
        self.imgV.frame = frame;
        UIView.setAnimationCurve(UIViewAnimationCurve.EaseOut) //设置动画相对速度
        UIView.commitAnimations()
        
        for (var i = 0; i < btns.count; i++){
            
            if curPage == i{
                btns[i].selected = true
            }else{
                btns[i].selected = false
            }
        }
}
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}