//
//  CheckUpdate.swift
//  CavyGame
//
//  Created by longjining on 15/8/27.
//  Copyright (c) 2015年 com.lvwenhan. All rights reserved.
//

import Foundation

class CheckUpdate : NSObject,  UIAlertViewDelegate{
    
    var needupdate : String!
    var downURL : String!
    
    class var shareInstance: CheckUpdate {
        struct Static {
            static var instance: CheckUpdate?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = CheckUpdate()
        }
        
        return Static.instance!
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int){
        if buttonIndex == 1{
            // 关闭 暂不更新
            if self.needupdate == "1" {
                // 强制更新 (退出app)
                exit(0)
            }
        }else{
            let preUrl = "itms-services://?action=download-manifest&url="
            
            let url = preUrl + self.downURL
            
            let ret : Bool = UIApplication.sharedApplication().openURL(NSURL(string: url)!)
            
            if (ret == false) {
                FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(Common.rootViewController.view, withTitle: Common.LocalizedStringForKey("install_fail"), delayTime: 2)
            }
            
            exit(0)
        }
    }
    
    func checkUpdate(){
        HttpHelper<UpdateInfo>.getVersionInfo { (result) -> () in
            
            if result == nil{
                
            }else{
                let versionInfo = result! as UpdateInfo
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    if versionInfo.build == nil{
                        return
                    }
                    let buildVersion = versionInfo.build;
                    self.needupdate = versionInfo.needupdate;
                    self.downURL = versionInfo.url;
                    let infoDictionary : NSDictionary = NSBundle.mainBundle().infoDictionary!
                    
                    // app build版本
                    let app_build : String = infoDictionary.objectForKey("CFBundleVersion") as! String!
                    
                    let intapp_build = app_build.toInt()
                    let intbuildVersion = buildVersion!.toInt()
                    if (intapp_build < intbuildVersion) {
                        
                        var strBtn1Title : String;
                        if self.needupdate == "1" {
                            // 强制更新 (退出app)
                            strBtn1Title = Common.LocalizedStringForKey("update_Btn1Title1")
                        }else{
                            strBtn1Title = Common.LocalizedStringForKey("update_Btn1Title2")
                        }
                        let alvertView = UIAlertView(title: Common.LocalizedStringForKey("update_title"), message: versionInfo.intro!, delegate: self, cancelButtonTitle: Common.LocalizedStringForKey("update_Btn2Title"), otherButtonTitles: strBtn1Title)
                        
                        alvertView.show();
                    }
                })
            }
        }
    }
}