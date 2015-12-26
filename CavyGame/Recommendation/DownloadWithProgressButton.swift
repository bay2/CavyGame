//
//  DownloadWithProgressButton.swift
//  CavyGame
//  可以显示进度的按钮
//  Created by longjining on 15/8/25.
//  Copyright (c) 2015年 com.lvwenhan. All rights reserved.
//

import UIKit

class DownloadWithProgressButton: DownloadButton {

    var downPress: UILabel!
    var whichPage : String = ""  // 按钮是属于哪个页面的(目前区分主页面和其它，用于接收，移除监听信息)
    let SETTING_KEY_DOWNINWIFI = "wifi"
    
    var itemInfo : GameSubInfo!{
        willSet{
            removeObserver()
        }
        
        didSet{
            initObsever()
            initBntSta()
        }
    }
    
    func initObsever(){
        
        if !whichPage.isEmpty{
            removePageObserver()
            var notifyName = whichPage
            
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "addObserver:", name: notifyName, object: nil)
            
            notifyName = Common.notifyRemove_PrePage + whichPage
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "removeObserver:", name: notifyName, object: nil)
        }
    }
    
    func initBntSta(){
        
        if nil != downPress {
            downPress.font = self.titleLabel?.font
        }
        
        var downInterFace = Down_Interface.getInstance()
        DownloadManager.getInstance().needUpdate(itemInfo.gameid, version: itemInfo.version, downUrl : itemInfo.downurl)
        var downItem = downInterFace.downFishItems_gameid(itemInfo.gameid)
        if downItem != nil{
        setBtnWithSta(downItem.downloadStatus.rawValue)
        
        }else{
        setBtnWithSta(DownBtnStatus.STATUS_Init)
        }
        
        // 添加监听
        addObserver()
    }
    
    func setBtnWithSta(btnSta : NSInteger){
        
        var title = Common.getStaByCode(btnSta);
        self.setTitle(title, forState: UIControlState.Normal)
        
        if downPress == nil {
            return
        }
        downPress.hidden = true

        switch (btnSta){
            
        case DownBtnStatus.STATUS_Init:
            self.setButtonImageStatus(DownBtnStatus_OC.STATUS_Down)
            break
        case DownBtnStatus.STATUS_Down:
            self.setTitle("", forState: UIControlState.Normal)
            self.showProgress(self.itemInfo.downLen!)
            self.setButtonImageStatus(DownBtnStatus_OC.STATUS_Down)
            downPress.hidden = false
            break
        case DownBtnStatus.STATUS_Ready:
            self.setTitle("", forState: UIControlState.Normal)
            self.showProgress(self.itemInfo.downLen!)
            self.setButtonImageStatus(DownBtnStatus_OC.STATUS_Down)
            downPress.hidden = false
            break
        case DownBtnStatus.STATUS_Pause:
            self.setButtonImageStatus(DownBtnStatus_OC.STATUS_Down)
             break
        case DownBtnStatus.STATUS_Succ:
            self.setButtonImageStatus(DownBtnStatus_OC.STATUS_Finish)
            break
        case DownBtnStatus.STATUS_Update:
            self.setButtonImageStatus(DownBtnStatus_OC.STATUS_Finish)
            break
        case DownBtnStatus.STATUS_Faild:
            self.setButtonImageStatus(DownBtnStatus_OC.STATUS_Pause)
            break
        default:
            break
        }
    }
    
    override func initBnt(){
        super.initBnt()
        
        // 添加进度条
        addProgressView()
    }
    
    func addObserver(notification:NSNotification){
        initBntSta()
    }
    
    func removeObserver(notification:NSNotification){
        removeObserver()
    }
    
    func clickDownBtn(){
        
        var downInterFace = Down_Interface.getInstance()
        
        if (downInterFace.isNotReachable()) {
            FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(self, withTitle: Common.LocalizedStringForKey("net_err"), delayTime: Common.alertDelayTime)

            return;
        }
        
        //使用https协议下载，规避缓存重定向问题
        var downurl = self.itemInfo.downurl! as NSString
        var range = downurl.rangeOfString("https")
        if (range.location == NSNotFound) {
            self.itemInfo.downurl = downurl.stringByReplacingOccurrencesOfString("http", withString: "https")
        }
        
        var keys =  NSArray(objects:"gamename", "version","downurl","plisturl", "pageName","filesize","icon","gameid")
        
        var values  = NSArray(objects:
            self.itemInfo.gamename!,
            self.itemInfo.version!,
            self.itemInfo.downurl!,
            self.itemInfo.plisturl!,
            self.itemInfo.packpagename!,
            self.itemInfo.filesize!,
            self.itemInfo.icon!,
            self.itemInfo.gameid!)
        
        var dicData = NSDictionary(objects:values as [AnyObject], forKeys:keys as [AnyObject] )
        
        downInterFace.buttonClicked(dicData as [NSObject : AnyObject])
      //  println("clickDownBtn")

        var downItemInfo = downInterFace.downFishItems_gameid(itemInfo.gameid)

        if downItemInfo != nil{
            // 暂停
            if NSInteger(downItemInfo.downloadStatus.rawValue) == DownBtnStatus.STATUS_Pause{
                downItem()
                return
            }
        }
        // 如果是wifi下需要提示  则需要等待通知
        
        if let switchOn = NSUserDefaults.standardUserDefaults().valueForKey(SETTING_KEY_DOWNINWIFI) as? Bool {
            
            if nil == downItemInfo {
                return
            }
            
            if NSInteger(downItemInfo.downloadStatus.rawValue) == DownBtnStatus.STATUS_Down ||
            NSInteger(downItemInfo.downloadStatus.rawValue) == DownBtnStatus.STATUS_Ready{
                self.setTitle("", forState: UIControlState.Normal)
                downPress.hidden = false
                downPress.text = "0%"
                return
            }
            return
        }else{
            downItem()
        }
    }
    
    func downItem(){
        
        var downInterFace = Down_Interface.getInstance()
        var downItem = downInterFace.downFishItems_gameid(itemInfo.gameid)
        if downItem != nil{
            self.itemInfo.downStd = downItem.downloadStatus.rawValue
            // 如果是完成则不改变文本
            if NSInteger(downItem.downloadStatus.rawValue) != DownBtnStatus.STATUS_Succ{
                
                if NSInteger(downItem.downloadStatus.rawValue) == DownBtnStatus.STATUS_Ready{
                    self.setTitle("", forState: UIControlState.Normal)
                    downPress.text = "0%"
                    downPress.hidden = false
                }else{
                    var title = Common.getStaByCode(downItem.downloadStatus.rawValue);
                    
                    self.setTitle(title, forState: UIControlState.Normal)
                    downPress.text = ""
                    downPress.hidden = true
                }
            }
        }else{
            self.setTitle("", forState: UIControlState.Normal)
            downPress.text = "0%"
        }
    }
    /*
    func installApp(){
    
        var downUrl : String = self.itemInfo.downurl!
        
        downUrl = downUrl.stringByReplacingOccurrencesOfString("http",withString:"https")
        downUrl = downUrl.stringByReplacingOccurrencesOfString(".ipa",withString:".plist")
        
        var plistUrl : String = "itms-services://?action=download-manifest&url="
        
        plistUrl = plistUrl + downUrl
        
        var ret : Bool = UIApplication.sharedApplication().openURL(NSURL(string: plistUrl)!)
        
        if (ret == false) {
            FVCustomAlertView.shareInstance.showDefaultErrorAlertOnView(self.superview!, withTitle: Common.LocalizedStringForKey("install_fail"), isClickDisappeared: true)
        }
    }
    */
    func addProgressView(){
        
        downPress = UILabel(frame: self.bounds)
        
        downPress.textColor = UIColor(hexString:"#3e76db")
        downPress.textAlignment = NSTextAlignment.Center
        self.addSubview(downPress)
    }
    
    func addObserver(){
        
        if self.itemInfo == nil{
            return
        }
        
        removeObserver()
        var notifyProgress = self.itemInfo.gameid
        var notificationPause = "Pause_" + self.itemInfo.gameid!
        var notificationDown = "Downloading_" + self.itemInfo.gameid!
        var notificationDelete = "Delete_" + self.itemInfo.gameid!
        var notificationSelContinue = "ContinueInGPRS_" + self.itemInfo.gameid!
        
        //实时监控下载进度
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updataProgress:", name: notifyProgress, object: nil)
        
        //暂停
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "downPause:", name: notificationPause, object: nil)
        
        //下载
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "downLoading:", name: notificationDown, object: nil)
        
        //删除
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "deleteDown:", name: notificationDelete, object: nil)
        
        //在非wifi下用户选择了继续下载
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "continueDown:", name: notificationSelContinue, object: nil)
    }
    
    func removeObserver(){
        if self.itemInfo == nil{
            return
        }
        var notifyProgress = self.itemInfo.gameid
        var notificationPause = "Pause_" + self.itemInfo.gameid!
        var notificationDown = "Downloading_" + self.itemInfo.gameid!
        var notificationDelete = "Delete_" + self.itemInfo.gameid!
        var notificationSelContinue = "ContinueInGPRS_" + self.itemInfo.gameid!
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name:notifyProgress, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name:notificationPause, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name:notificationDown, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name:notificationDelete, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name:notificationSelContinue, object: nil)
    }
    
    /**进度条*/
    func updataProgress(notification:NSNotification){
        
        dispatch_async(dispatch_get_main_queue(), {
            
            var dicData = notification.object as! NSDictionary
            
            var gameid : String = dicData.valueForKey("gameid") as! String
            
            if (gameid != self.itemInfo.gameid){
                return;
            }
            
            var downLen = dicData.valueForKey("downloadLength")?.doubleValue
            
            var downSta = dicData.valueForKey("downloadStatus")?.integerValue
            
            if downSta == DownBtnStatus.STATUS_Succ{
                self.downPress.hidden = true
                var title = Common.getStaByCode(DownBtnStatus.STATUS_Succ);
                self.setTitle(title, forState: UIControlState.Normal)
                self.downPress.text = ""
                self.setButtonImageStatus(DownBtnStatus_OC.STATUS_Finish)
                return;
            }
            if downSta == DownBtnStatus.STATUS_Faild{
                self.downPress.hidden = true
                var title = Common.getStaByCode(DownBtnStatus.STATUS_Faild);
                self.setTitle(title, forState: UIControlState.Normal)
                self.downPress.text = ""
                self.setButtonImageStatus(DownBtnStatus_OC.STATUS_Pause)
                return;
            }
            
            if downSta != DownBtnStatus.STATUS_Down{
                return
            }
            
            self.showProgress(downLen!)
        })
    }
    
    func downPause(notification:NSNotification){
        // 暂停后显示继续
        
        dispatch_async(dispatch_get_main_queue(), {
            
            self.setBtnWithSta(DownBtnStatus.STATUS_Pause)
            
            var title = Common.getStaByCode(DownBtnStatus.STATUS_Pause);
            self.setTitle(title, forState: UIControlState.Normal)
            self.downPress.hidden = true
        })
    }
    
    func downLoading(notification:NSNotification){

        dispatch_async(dispatch_get_main_queue(), {
            
            self.setBtnWithSta(DownBtnStatus.STATUS_Down)
        })
    }
    
    func deleteDown(notification:NSNotification){
        
        dispatch_async(dispatch_get_main_queue(), {
            
            self.setBtnWithSta(DownBtnStatus.STATUS_Init)

            self.downPress.text = "0%"
        })
    }

    func showProgress(downLen : Double){
        
        var downPercent = downLen / Common.M_SIZE
        
        var strFileSize = NSString(string: self.itemInfo.filesize!)
        var fileSize = strFileSize.doubleValue
        downPercent = downPercent * 100.0 / fileSize
        
        if downPercent > 100{
            downPercent = 100
        }
        var strDowPer = String(format: "%d", Int(downPercent))
        strDowPer = strDowPer + "%"
        downPress.text = strDowPer
        
      //  println("showProgress")
        if downPress.hidden{
            downPress.hidden = false
        }
        
        var text = self.titleForState(UIControlState.Normal)
        if (text != ""){
            self.setButtonImageStatus(DownBtnStatus_OC.STATUS_Down)
            
            self.setTitle("", forState: UIControlState.Normal)
            text = self.titleForState(UIControlState.Normal)
        }
    }
    
    func continueDown(notification:NSNotification){
        downItem()
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    override func removeFromSuperview(){
    
        super.removeFromSuperview()
    
        removeObserver()
        removePageObserver()
    }
    
    func removePageObserver(){
        
        if !whichPage.isEmpty{
            var notifyName = whichPage
            
            NSNotificationCenter.defaultCenter().removeObserver(self, name:notifyName, object: nil)
            
            notifyName = Common.notifyRemove_PrePage + whichPage
            NSNotificationCenter.defaultCenter().removeObserver(self, name:notifyName, object: nil)
        }
    }
}
