//
//  RegisterViewController.swift
//  CavyGame
//
//  Created by xuemincai on 15/7/30.
//  Copyright (c) 2015年 com.lvwenhan. All rights reserved.
//

import UIKit

class RegisterViewController: UserLogin {

    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var phoneNumTxt: UITextField!
    @IBOutlet weak var authCodeTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var sendCodeBtn: UIButton!
    @IBOutlet weak var protocolBtn: UIButton!
    @IBOutlet weak var emailBarBtn: UIBarButtonItem!
    var timmer:NSTimer = NSTimer()
    var second = 60
    var isStartTime = false
    var isRead = false
    @IBOutlet weak var offBtn: UIButton!
    @IBOutlet var protocolView: UIView!

    @IBOutlet weak var regLabel1: UILabel!
    @IBOutlet weak var onBtn: UIButton!
    @IBOutlet weak var registerSubView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = Common.LocalizedStringForKey("registerView_title")
        regLabel1.text = Common.LocalizedStringForKey("regLabel1")
        protocolBtn.setTitle(Common.LocalizedStringForKey("protocolBtn"), forState: UIControlState.allZeros)
        
        sendCodeBtn.setTitle(Common.LocalizedStringForKey("sendCode"), forState: UIControlState.allZeros)
        sendCodeBtn.setTitleColor(UIColor.lightGrayColor(), forState: UIControlState.Highlighted)
        
        phoneNumTxt.placeholder = Common.LocalizedStringForKey("registerView_phonenum_txt")
        authCodeTxt.placeholder = Common.LocalizedStringForKey("registerView_authCode_txt")
        passwordTxt.placeholder = Common.LocalizedStringForKey("loginView_password_txt")
        emailBarBtn.title = Common.LocalizedStringForKey("emailBarBtn")
        
        registerBtn.setTitle(Common.LocalizedStringForKey("registerBtn"), forState: UIControlState.allZeros)
        
        
        
        
        phoneNumTxt.delegate = self
        authCodeTxt.delegate = self
        registerBtn.layer.masksToBounds = true
        registerBtn.layer.cornerRadius = Common.btnCornerRadius
        registerBtn.setBackgroundCoclor(UIColor(hexString: "3e76db"), forState: UIControlState.Highlighted)
        
        registerSubView.layer.borderWidth = 0.6
        registerSubView.layer.borderColor = UIColor(hexString: "DEDEDF")?.CGColor
        
        if "en" == Common.getPreferredLanguage() {
            protocolView.hidden = true
        }
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
    点击注册
    
    :param: sender <#sender description#>
    */
    @IBAction func onClickRegister(sender: UIButton) {
        
        //参数有效性校验
        if phoneNumTxt.text.isEmpty {
            FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(view, withTitle: Common.LocalizedStringForKey("register_phone_err"), delayTime: Common.alertDelayTime)
            return
        }
        
        if authCodeTxt.text.isEmpty {
            FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(view, withTitle: Common.LocalizedStringForKey("register_auth_code"), delayTime: Common.alertDelayTime)
            return
        }
        
        if passwordTxt.text.isEmpty {
            FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(view, withTitle: Common.LocalizedStringForKey("login_enter_passwd"), delayTime: Common.alertDelayTime)
            return
        }
        
        if !Common.isTelNumber(phoneNumTxt.text) {
            FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(view, withTitle: Common.LocalizedStringForKey("register_phone_err2"), delayTime: Common.alertDelayTime)
            return
        }
        
        if 6 > count(passwordTxt!.text!) {
            
            FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(view, withTitle: Common.LocalizedStringForKey("register_passwd_num_err"), delayTime: Common.alertDelayTime)
            
            return
        }
        
        if "zh" == Common.getPreferredLanguage() {
            
            if !isRead {
                
                FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(view, withTitle: Common.LocalizedStringForKey("register_rand_err"), delayTime: Common.alertDelayTime)
                
                return
                
            }
            
        }
        
        var loadView = FVCustomAlertView.shareInstance.showDefaultLoadingAlertOnView(self.view, withTitle: Common.LocalizedStringForKey("SDRefreshViewRefreshingStateText"), isClickDisappeared: true)
        
        HttpHelper<CommmonMsgRet>.registerUser(phoneNumTxt.text, regtype : 0,  passwd: passwordTxt.text.md5(), authCode: authCodeTxt.text) { (result) -> () in
            
            if let code = result?.code { //HTTP成功返回
                
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                if  code == "1001" { //注册成功处理
                    
                    //注册成功自动登录
                        self.userlogin(self.phoneNumTxt.text, passwd: self.passwordTxt.text) { (isLoginSucce, msg) -> () in
                            
                            if LoginReturn.LoginSucceed == isLoginSucce {
                                
                                self.savePasswd(self.passwordTxt.text)
                                self.saveUserName(self.phoneNumTxt.text)
                                self.setIsLogin(true)
                                
                                Common.rootViewController.leftViewController.UpdateUserName(Common.userInfo.nikename!)
                                Common.rootViewController.showLeft()
                                
                                FVCustomAlertView.shareInstance.hideAlert(loadView!)
                                
                                
                            } else {
                                
                                if (nil == msg) {
                                    
                                    FVCustomAlertView.shareInstance.hideAlert(loadView!)
                                    
                                    FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(self.view, withTitle: Common.LocalizedStringForKey("net_err"),  delayTime: Common.alertDelayTime)
                                    return
                                    
                                }
                                
                                FVCustomAlertView.shareInstance.hideAlert(loadView!)
                                
                                FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(self.view, withTitle: msg!, delayTime: Common.alertDelayTime)
                                
                            }
                        }
                    
                } else { //注册失败
                    
                    FVCustomAlertView.shareInstance.hideAlert(loadView!)
                    
                    FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(self.view, withTitle: result!.msg!, delayTime: Common.alertDelayTime)
                }
                    
                })
        
            } else { //HTTP 返回不正确
                
                FVCustomAlertView.shareInstance.hideAlert(loadView!)
                
                FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(self.view, withTitle: Common.LocalizedStringForKey("net_err"), delayTime: Common.alertDelayTime)
                
            }
            
        }
        
    }
    
    /**
    点击发送验证
    
    :param: sender
    */
    @IBAction func onClickSendCode(sender: UIButton) {
        
        if phoneNumTxt.text.isEmpty {
            FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(self.view, withTitle: Common.LocalizedStringForKey("register_phone_err"),  delayTime: Common.alertDelayTime)
            return
        }
        
        if !Common.isTelNumber(phoneNumTxt.text) {
            
            FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(self.view, withTitle: Common.LocalizedStringForKey("register_phone_err2"),  delayTime: Common.alertDelayTime)
            return
        }
        
        self.sendCodeBtn.enabled = false
        
        //请求验证码
        HttpHelper<CommmonMsgRet>.sendPhoneCode(phoneNumTxt.text, forgetpwd : false) { (result) -> () in
            
            dispatch_async(dispatch_get_main_queue(), {
            
                if let code = result?.code { //HTTP返回成功
                
                    if  code == "1001" { //验证码发送成功
                    
                    
                        var strsecond = "\(self.second)" + Common.LocalizedStringForKey("second")
                        self.sendCodeBtn.setTitle(strsecond, forState: UIControlState.Normal)
                    
                        self.isStartTime = true
                    
                    } else { //验证码发送失败
                    
                        self.isStartTime = false
                        self.sendCodeBtn.enabled = true
                        FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(self.view, withTitle: "\(result!.msg!)", delayTime: Common.alertDelayTime)
                    }
                
                } else { //HTTP返回失败
                    
                    self.second = 0
                    self.sendCodeBtn.enabled = false
                    FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(self.view, withTitle: Common.LocalizedStringForKey("net_err"), delayTime: Common.alertDelayTime)
                }
            })
        }
        
        //启动定时器进行60s倒计时
        timmer.invalidate()
        timmer = NSTimer.scheduledTimerWithTimeInterval(1.0, target:self, selector:"refreshBtn", userInfo:nil, repeats:true)
    }
    
    @IBAction func onClickBack(sender: UIBarButtonItem) {
        
        self.navigationController?.popViewControllerAnimated(true)
        
    }
    /**
    点击勾选
    
    :param: sender 
    */
    @IBAction func onClickCheck(sender: UIButton) {
        
        if sender.restorationIdentifier == "check_off" {
            
            onBtn.hidden = false
            offBtn.hidden = true
            isRead = true
            
        } else {
            
            onBtn.hidden = true
            offBtn.hidden = false
            isRead = false
            
        }
        
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
            sendCodeBtn.setTitle(Common.LocalizedStringForKey("sendCode"), forState: UIControlState.Normal)
            second = 60
            sendCodeBtn.enabled = true
            isStartTime = false
            return
        }
        
        second--
        var strSecond = "\(second)" + Common.LocalizedStringForKey("second")
        sendCodeBtn.setTitle(strSecond, forState: UIControlState.Normal)
        
    }

    @IBAction func onClickEmail(sender: UIBarButtonItem) {

        var eMailVc : EmailRegisterViewController?
        
        if .UIDeviceResolution_iPhoneRetina4 == resolution() {
            
            eMailVc = UIStoryboard(name: "Register_iPhone4", bundle: nil).instantiateViewControllerWithIdentifier("EmailRegisterView") as? EmailRegisterViewController
            
        } else {
            
            eMailVc = Common.getViewControllerWithIdentifier("Register", identifier: "EmailRegisterView") as? EmailRegisterViewController
            
        }
        
        self.navigationController?.pushViewController(eMailVc!, animated: true)
        
    }
    
    @IBAction func onClickProtocol(sender: AnyObject) {
        
        var protocolVc = Common.getViewControllerWithIdentifier("Register", identifier: "ProtocolView") as! ProtocolViewController
        
        self.navigationController?.pushViewController(protocolVc, animated: true)
    }

}

// MARK: - 文本框代理
extension RegisterViewController : UITextFieldDelegate {
    
    
    /**
    输入限制
    
    :param: textField <#textField description#>
    :param: range     <#range description#>
    :param: string    <#string description#>
    
    :returns: <#return value description#>
    */
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        var num = string.toInt()
        
        if nil == num && "" != string {
            
            return false
        }
        
        if textField == phoneNumTxt {
            
            var toString = textField.text + (string as String)
                
            if 11 < count(toString) {
                    
                return false
                    
            }
            return true
        
        }
        
        if textField == authCodeTxt {
            
            
            var toString = textField.text + (string as String)
            
            if 4 < count(toString) {
                
                return false
                
            }
        }
        
        
        return true
        
    }
    

}
