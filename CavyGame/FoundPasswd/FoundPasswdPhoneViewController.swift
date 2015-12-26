//
//  FoundPasswdPhoneViewController.swift
//  CavyGame
//
//  Created by xuemincai on 15/8/29.
//  Copyright (c) 2015年 com.lvwenhan. All rights reserved.
//

import UIKit

class FoundPasswdPhoneViewController: UIViewController {

    @IBOutlet weak var phoentext: UITextField!
    @IBOutlet weak var codetext: UITextField!
    @IBOutlet weak var passwdtxt: UITextField!
    @IBOutlet weak var passwd2txt: UITextField!
    @IBOutlet weak var codeBtn: UIButton!
    @IBOutlet weak var finishBtn: UIButton!
    @IBOutlet weak var foundPwd: UIBarButtonItem!
    
    var second = 60
    var isStartTime = false
    var timmer:NSTimer = NSTimer()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = Common.LocalizedStringForKey("FoundPasswd")
        
        foundPwd.title = Common.LocalizedStringForKey("emailBarBtn")
        
        finishBtn.setTitle(Common.LocalizedStringForKey("finishBtn"), forState: UIControlState.allZeros)
        codeBtn.setTitle(Common.LocalizedStringForKey("sendCode"), forState: UIControlState.allZeros)
        codeBtn.setTitleColor(UIColor.lightGrayColor(), forState: UIControlState.Highlighted)
        
        phoentext.placeholder = Common.LocalizedStringForKey("registerView_phonenum_txt")
        codetext.placeholder = Common.LocalizedStringForKey("registerView_authCode_txt")
        passwdtxt.placeholder = Common.LocalizedStringForKey("loginView_password_txt")
        passwd2txt.placeholder = Common.LocalizedStringForKey("loginView_password2_txt")
        
        
        
        
        phoentext.delegate = self
        codetext.delegate = self
        finishBtn.layer.masksToBounds = true
        finishBtn.layer.cornerRadius = Common.btnCornerRadius
        finishBtn.setBackgroundCoclor(UIColor(hexString: "3e76db"), forState: UIControlState.Highlighted)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onClickBack(sender: UIBarButtonItem) {
        
        self.navigationController?.popViewControllerAnimated(true)
        
    }


    
    @IBAction func onClickEmail(sender: UIBarButtonItem) {
        
        var emailVc : FoundPasswordEmailViewController?
        
        if .UIDeviceResolution_iPhoneRetina4 == resolution() {
            
            emailVc = UIStoryboard(name: "FoundPasswd_iPhone4", bundle: nil).instantiateViewControllerWithIdentifier("FoundPasswordEmail") as? FoundPasswordEmailViewController
            
        } else {
            
            emailVc = Common.getViewControllerWithIdentifier("FoundPasswd", identifier: "FoundPasswordEmail") as? FoundPasswordEmailViewController
        }
        
        self.navigationController?.pushViewController(emailVc!, animated: true)
    }
    
    /**
    点击发送验证码
    
    :param: sender 
    */
    @IBAction func onClickSendCode(sender: UIButton) {
        
        if phoentext.text.isEmpty {
            FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(self.view, withTitle: Common.LocalizedStringForKey("register_phone_err"), delayTime: Common.alertDelayTime)
            return
        }
        
        if !Common.isTelNumber(phoentext.text) {
            
            FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(self.view, withTitle: Common.LocalizedStringForKey("register_phone_err2"), delayTime: Common.alertDelayTime)
            return
        }
        
        self.codeBtn.enabled = false
        
        //请求验证码
        HttpHelper<CommmonMsgRet>.sendPhoneCode(phoentext.text, forgetpwd : true) { (result) -> () in
            
            dispatch_async(dispatch_get_main_queue(), {

                if let code = result?.code { //HTTP返回成功
                
                    if  code == "1001" { //验证码发送成功
                    
                    
                        var strsecond = "\(self.second)" + Common.LocalizedStringForKey("second")
                        self.codeBtn.setTitle(strsecond, forState: UIControlState.Normal)
                        
                    
                        self.isStartTime = true
                    
                    } else { //验证码发送失败
                    
                        self.isStartTime = false
                        self.codeBtn.enabled = true
                        FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(self.view, withTitle: "\(result!.msg!)", delayTime: Common.alertDelayTime)
                    }
                
                } else { //HTTP返回失败
                    self.second = 0
                    self.codeBtn.enabled = false
                    FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(self.view, withTitle: Common.LocalizedStringForKey("senCodeErr"), delayTime: Common.alertDelayTime)
                }
            })            
        }
        
        //启动定时器进行60s倒计时
        timmer.invalidate()
        timmer = NSTimer.scheduledTimerWithTimeInterval(1.0, target:self, selector:"refreshBtn", userInfo:nil, repeats:true)
        
    }
    
    /**
    定时器处理 -- 不断刷新发送验证码按钮
    */
    func refreshBtn() {
        
        if self.isStartTime == false {
            return
        }
        
        if 0 >= second {
            timmer.invalidate()
            codeBtn.setTitle(Common.LocalizedStringForKey("sendCode"), forState: UIControlState.Normal)
            second = 60
            codeBtn.enabled = true
            isStartTime = false
            return
        }
        
        second--
        var strSecond = "\(second)" + Common.LocalizedStringForKey("second")
        codeBtn.setTitle(strSecond, forState: UIControlState.Normal)
        
    }
    
    @IBAction func onClickFinish(sender: UIButton) {
        
        if phoentext.text.isEmpty {
            FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(self.view, withTitle: Common.LocalizedStringForKey("register_phone_err"), delayTime: Common.alertDelayTime)
            return
        }
        
        if codetext.text.isEmpty {
            FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(self.view, withTitle: Common.LocalizedStringForKey("register_auth_code"), delayTime: Common.alertDelayTime)
            return
        }
        
        if passwdtxt.text.isEmpty {
            
            FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(self.view, withTitle: Common.LocalizedStringForKey("login_enter_passwd"), delayTime: Common.alertDelayTime)
            return
            
        }
        
        if passwd2txt.text.isEmpty {
            
            FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(self.view, withTitle: Common.LocalizedStringForKey("login_enter_passwd"), delayTime: Common.alertDelayTime)
            return
            
        }
        
        if 6 > count(passwdtxt!.text!) {
            
            FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(view, withTitle: Common.LocalizedStringForKey("register_passwd_num_err"), delayTime: Common.alertDelayTime)
            
            return
        }
        
        if passwd2txt.text != passwdtxt.text {
            
            FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(self.view, withTitle: Common.LocalizedStringForKey("foundpasswd_err"), delayTime: Common.alertDelayTime)
            return
            
        }
        
        var loadView = FVCustomAlertView.shareInstance.showDefaultLoadingAlertOnView(self.view, withTitle: Common.LocalizedStringForKey("SDRefreshViewRefreshingStateText"), isClickDisappeared: true)
        
        HttpHelper<CommmonMsgRet>.foundpwdCodeCheck(phoentext.text, code: codetext.text) { (result) -> () in
            
            dispatch_async(dispatch_get_main_queue(), {
                
            
                if nil == result?.code {
                    FVCustomAlertView.shareInstance.hideAlert(loadView!)
                    FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(self.view, withTitle: Common.LocalizedStringForKey("net_err"), delayTime: Common.alertDelayTime)
                    return
                }
            
                if "1001" != result?.code {
                
                    FVCustomAlertView.shareInstance.hideAlert(loadView!)
                    FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(self.view, withTitle: result!.msg!, delayTime: Common.alertDelayTime)
                
                    return
                }
                
                HttpHelper<CommmonMsgRet>.phoneModifyPwd(self.phoentext.text, pwd: self.passwd2txt.text.md5(), completionHandlerRet: { (result) -> () in
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        FVCustomAlertView.shareInstance.hideAlert(loadView!)
                    
                        if nil == result?.code {
                            FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(self.view, withTitle: Common.LocalizedStringForKey("net_err"), delayTime: Common.alertDelayTime)
                            return
                        }
                        
                        FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(self.view, withTitle: result!.msg!, delayTime: Common.alertDelayTime)
                        
                        if "1001" == result?.code! {
                            
                            self.navigationController?.popViewControllerAnimated(true)
                            
                        }
                        
                    })
                })
            
            })
            
            
            return
        }
    }
    

}

// MARK: - 文本框代理
extension FoundPasswdPhoneViewController : UITextFieldDelegate {
    
    
    /**
    输入限制
    
    :param: textField
    :param: range
    :param: string
    
    :returns: 
    */
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        var num = string.toInt()
        
        if nil == num && "" != string {
            
            return false
        }
        
        if textField == phoentext {
            
            var toString = textField.text + (string as String)
            
            if 11 < count(toString) {
                
                return false
                
            }
            return true
            
        }
        
        if textField == codetext {
            
            
            var toString = textField.text + (string as String)
            
            if 4 < count(toString) {
                
                return false
                
            }
        }
        
        return true
        
    }
    
}
