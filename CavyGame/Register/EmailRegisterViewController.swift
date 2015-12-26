//
//  EmailRegisterViewController.swift
//  CavyGame
//
//  Created by xuemincai on 15/8/28.
//  Copyright (c) 2015年 com.lvwenhan. All rights reserved.
//

import UIKit

class EmailRegisterViewController: UserLogin {

    @IBOutlet weak var imageCode: UIImageView!
    @IBOutlet weak var offBtn: UIButton!
    @IBOutlet weak var onBtn: UIButton!
    var isRead : Bool = false

    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var codeText: UITextField!
    @IBOutlet weak var passwdText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var regLabel1: UILabel!
    @IBOutlet weak var protocolBtn: UIButton!
    @IBOutlet weak var phoneBarItem: UIBarButtonItem!
    @IBOutlet weak var protocolView: UIView!
    @IBOutlet weak var registerSubView: UIView!
    
    var loadingView : UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = Common.LocalizedStringForKey("registerView_title")
        registerBtn.setTitle(Common.LocalizedStringForKey("registerBtn"), forState: UIControlState.allZeros)
        protocolBtn.setTitle(Common.LocalizedStringForKey("protocolBtn"), forState: UIControlState.allZeros)
        phoneBarItem.title = Common.LocalizedStringForKey("phoneBarItem")
        
        codeText.placeholder = Common.LocalizedStringForKey("sendCode")
        passwdText.placeholder = Common.LocalizedStringForKey("loginView_password_txt")
        emailText.placeholder = Common.LocalizedStringForKey("emailText")
        regLabel1.text = Common.LocalizedStringForKey("regLabel1")
        
        serverAddr
        
        imageCode.setWebImage(serverAddr + "authority/imageCode?codekey=1", network: true)
        
        codeText.delegate = self
        registerBtn.layer.masksToBounds = true
        registerBtn.layer.cornerRadius = Common.btnCornerRadius
        registerBtn.setBackgroundCoclor(UIColor(hexString: "3e76db"), forState: UIControlState.Highlighted)
        
        var tap = UITapGestureRecognizer(target: self, action: "onClickCodeImage:")
        imageCode!.addGestureRecognizer(tap)
        imageCode.userInteractionEnabled = true
        registerSubView.layer.borderWidth = 0.6
        registerSubView.layer.borderColor = UIColor(hexString: "DEDEDF")?.CGColor
        
        if "en" == Common.getPreferredLanguage() {
            protocolView.hidden = true
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
    点击验证码
    
    :param: tap <#tap description#>
    */
    func onClickCodeImage(tap: UITapGestureRecognizer){
        
        imageCode.reloadWebImage(serverAddr + "authority/imageCode?codekey=1", network: true)
        
    }
    
    
    /**
    点击返回
    
    :param: sender <#sender description#>
    */
    @IBAction func onClickBack(sender: UIBarButtonItem) {
        
        self.navigationController?.popToViewController(self.navigationController?.viewControllers[1] as! UIViewController, animated: true)
        
    }

    /**
    点击手机注册
    
    :param: sender <#sender description#>
    */
    @IBAction func onClickPhone(sender: UIBarButtonItem) {
        
        self.navigationController?.popViewControllerAnimated(true)
        
    }

    /**
    点击复选按钮
    
    :param: sender <#sender description#>
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
    点击注册处理
    
    :param: sender <#sender description#>
    */
    @IBAction func onClickReg(sender: UIButton) {
        
        if emailText.text.isEmpty {
            
            FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(self.view, withTitle: Common.LocalizedStringForKey("register_email_nil"), delayTime: Common.alertDelayTime)
            
            return
            
        }
        
        if !Common.isEmall(emailText.text) {
            
            FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(self.view, withTitle: Common.LocalizedStringForKey("register_email_err"), delayTime: Common.alertDelayTime)
            
            return
            
        }
        
        if codeText.text.isEmpty {
            
            FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(self.view, withTitle: Common.LocalizedStringForKey("register_auth_code"), delayTime: Common.alertDelayTime)
            return
        }
        
        
        if passwdText.text.isEmpty {
            
            FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(self.view, withTitle: Common.LocalizedStringForKey("login_enter_passwd"), delayTime: Common.alertDelayTime)
            return
            
        }
        
        if "zh" == Common.getPreferredLanguage() {

            if !isRead {
            
                FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(self.view, withTitle: Common.LocalizedStringForKey("register_rand_err"), delayTime: Common.alertDelayTime)
                return
            
            }
        }
        
        if 6 > count(passwdText!.text!) {
            
            FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(view, withTitle: Common.LocalizedStringForKey("register_passwd_num_err"), delayTime: Common.alertDelayTime)
            
            return
        }
        
        self.loadingView = FVCustomAlertView.shareInstance.showDefaultLoadingAlertOnView(self.view, withTitle: Common.LocalizedStringForKey("SDRefreshViewRefreshingStateText"), isClickDisappeared: true)
        
        HttpHelper<CommmonMsgRet>.emailCodeCheck(emailText.text, pwd: passwdText.text.md5(), code: codeText.text) { (result) -> () in
            
            dispatch_async(dispatch_get_main_queue(), {
            
                if nil == result?.code {
                    
                    FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(self.view, withTitle: Common.LocalizedStringForKey("net_err"), delayTime: Common.alertDelayTime)
                    
                    return
                    
                }
                
                
                if result?.code != "1001" {
                    
                    FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(self.view, withTitle: result!.msg!, delayTime: Common.alertDelayTime)
                    return
                    
                }
                
                self.userRegister()
            
            })
            
        }
        
    }
    /**
    用户注册
    */
    func userRegister() {
        
        
        HttpHelper<CommmonMsgRet>.registerUser(emailText.text, regtype : 1, passwd: passwdText.text.md5(), authCode: codeText.text) { (result) -> () in
            
            dispatch_async(dispatch_get_main_queue(), {
                                
                if nil == result?.code {
                    
                    if self.loadingView != nil {
                        FVCustomAlertView.shareInstance.hideAlert(self.loadingView!)
                    }
                    
                    FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(self.view, withTitle: Common.LocalizedStringForKey("net_err"), delayTime: Common.alertDelayTime)
                    return
                    
                }
                
                if result?.code != "1001" {
                    
                    if self.loadingView != nil {
                        FVCustomAlertView.shareInstance.hideAlert(self.loadingView!)
                    }
                    
                    FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(self.view, withTitle: result!.msg!, delayTime: Common.alertDelayTime)
                    return
                    
                }
                
                self.userlogin(self.emailText.text, passwd: self.passwdText.text, isLogin: { (isLoginSucce, msg) -> () in
                    
                    if self.loadingView != nil {
                        FVCustomAlertView.shareInstance.hideAlert(self.loadingView!)
                    }
                    
                    
                    if LoginReturn.LoginSucceed == isLoginSucce {
                        
                        self.savePasswd(self.passwdText.text)
                        self.saveUserName(self.emailText.text)
                        self.setIsLogin(true)
                        
                        Common.rootViewController.leftViewController.UpdateUserName(Common.userInfo.nikename!)
                        Common.rootViewController.showLeft()
                        
                    } else {
                        
                        if msg == nil {
                            
                            FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(self.view, withTitle: Common.LocalizedStringForKey("net_err"), delayTime: Common.alertDelayTime)
                            
                            return
                            
                        }
                        
                        FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(self.view, withTitle: msg!, delayTime: Common.alertDelayTime)
                    }
                    
                })
            })
        }
        
    }
    @IBAction func onClickProtocol(sender: AnyObject) {
        
        var protocolVc = Common.getViewControllerWithIdentifier("Register", identifier: "ProtocolView") as! ProtocolViewController
        
        self.navigationController?.pushViewController(protocolVc, animated: true)
        
    }

}

extension EmailRegisterViewController : UITextFieldDelegate {
    
    /**
    输入限制
    
    :param: textField <#textField description#>
    :param: range     <#range description#>
    :param: string    <#string description#>
    
    :returns: <#return value description#>
    */
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        var num = string.toInt()

        if textField == codeText {
            
            
            var toString = textField.text + (string as String)
            
            if 4 < count(toString) {
                
                return false
                
            }
        }
        
        
        return true
        
    }

    
}
