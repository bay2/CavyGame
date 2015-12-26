//
//  RegisterViewController.swift
//  CavyGame
//
//  Created by xuemincai on 15/7/28.
//  Copyright (c) 2015年 com.lvwenhan. All rights reserved.
//

import UIKit

class LoginViewController: UserLogin {

    @IBOutlet weak var userNameText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var cbonBtn: UIButton!
    @IBOutlet weak var cboffBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    var savePassword: Bool!
    var alertView : UIView?
    @IBOutlet weak var savePasswordLabel: UILabel!
    @IBOutlet weak var foundPwdBtn: UIButton!
    @IBOutlet weak var regBarItem: UIBarButtonItem!

    override func viewDidLoad() {
    
        userNameText.placeholder = Common.LocalizedStringForKey("loginView_username_txt")
        
        passwordText.placeholder = Common.LocalizedStringForKey("loginView_password_txt")
        
        self.title = Common.LocalizedStringForKey("loginView_title")
        loginBtn.layer.masksToBounds = true
        loginBtn.layer.cornerRadius = Common.btnCornerRadius
        loginBtn.setBackgroundCoclor(UIColor(hexString: "3e76db"), forState: UIControlState.Highlighted)
        
        savePasswordLabel.text = Common.LocalizedStringForKey("loginsavepwd_label")
        loginBtn.setTitle(Common.LocalizedStringForKey("login_view_btn"), forState: UIControlState.allZeros)
        foundPwdBtn.setTitle(Common.LocalizedStringForKey("login_foundpwd_label"), forState: UIControlState.allZeros)
        regBarItem.title = Common.LocalizedStringForKey("registerView_title")
        
        savePasswordLabel.userInteractionEnabled = true
        savePasswordLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onClickSavePassword:"))
        
        
        
        //读取用户名、密码
        userNameText.text = getUserName()
        
        if  true == isSavePasswd() {
            
            cbonBtn.hidden = false
            cboffBtn.hidden = true
            savePassword = true
            passwordText.text = getPasswd()
            
        } else {
            
            cbonBtn.hidden = true
            cboffBtn.hidden = false
            savePassword = false
            
        }
    }
    
    func onClickSavePassword(tap : UITapGestureRecognizer) {
        
        if  false == savePassword {
            
            cbonBtn.hidden = false
            cboffBtn.hidden = true
            savePassword = true
            
        } else {
            
            cbonBtn.hidden = true
            cboffBtn.hidden = false
            savePassword = false
            
        }
        
    }
    

    @IBAction func onClickBack(sender: UIBarButtonItem) {
        
        self.navigationController?.popViewControllerAnimated(true)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /**
    点击登录按钮处理
    
    :param: sender 
    */
    @IBAction func onClickLogin(sender: UIButton) {
        
        if  userNameText.text.isEmpty {
            FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(self.view, withTitle: Common.LocalizedStringForKey("login_enter_username"), delayTime: Common.alertDelayTime)
            
            return
        }
        
        if passwordText.text.isEmpty {
            
            FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(self.view, withTitle: Common.LocalizedStringForKey("login_enter_passwd"), delayTime: Common.alertDelayTime)
            
            return
        }
        
        if (!Common.isEmall(userNameText.text) && !Common.isTelNumber(userNameText.text)) {
            
            FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(self.view, withTitle: Common.LocalizedStringForKey("login_enter_username_error"), delayTime: Common.alertDelayTime)
            return
            
        }
        
        loginBtn.enabled = false
        alertView = FVCustomAlertView.shareInstance.showDefaultLoadingAlertOnView(self.view, withTitle: Common.LocalizedStringForKey("SDRefreshViewRefreshingStateText"), isClickDisappeared: false)
        
        userlogin(userNameText.text, passwd: passwordText.text) { (isLoginSucce, msg) -> () in
            
            FVCustomAlertView.shareInstance.hideAlert(self.alertView!)
            
            self.loginBtn.enabled = true
            
            FVCustomAlertView.shareInstance.hideAlertFromView(self.alertView!, fading: true)
            
            if (LoginReturn.LoginSucceed == isLoginSucce) {
                
                self.savePasswd(self.passwordText.text)
                self.setSavePasswd(self.savePassword)
                Common.rootViewController.leftViewController.UpdateUserName(Common.userInfo.nikename!)
                Common.rootViewController.leftViewController.setAvatarImage()
                Common.rootViewController.showLeft()
                
            } else {
                
                if nil == msg {
                    
                    FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(self.view, withTitle: Common.LocalizedStringForKey("net_err"), delayTime: Common.alertDelayTime)
                    
                } else {
                    
                    FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(self.view, withTitle: Common.LocalizedStringForKey("login_loginerr"), delayTime: Common.alertDelayTime)
                    
                }
                
                
                
                
                
                return
            }
        }
        
        saveUserName(userNameText.text)
    }
    
    /**
    点击忘记密码
    
    :param: sender 
    */
    @IBAction func onClickFoundPasswd(sender: UIButton) {
        
        var foundPasswdVc : FoundPasswdPhoneViewController?
        
        if .UIDeviceResolution_iPhoneRetina4 == resolution() {
            
            foundPasswdVc = UIStoryboard(name: "FoundPasswd_iPhone4", bundle: nil).instantiateViewControllerWithIdentifier("FoundPasswdPhone") as? FoundPasswdPhoneViewController
            
        } else {
            
            foundPasswdVc = Common.getViewControllerWithIdentifier("FoundPasswd", identifier: "FoundPasswdPhone") as? FoundPasswdPhoneViewController
            
        }
        
        self.navigationController?.pushViewController(foundPasswdVc!, animated: true)
        
    }
    
    /**
    点击注册处理
    
    :param: sender
    */
    @IBAction func onClickReg(sender: UIBarButtonItem) {
        
        var regVc : RegisterViewController?
        
        if .UIDeviceResolution_iPhoneRetina4 == resolution() {
            
            regVc = UIStoryboard(name: "Register_iPhone4", bundle: nil).instantiateViewControllerWithIdentifier("RegisterView") as? RegisterViewController
            
        } else {
            
            regVc = Common.getViewControllerWithIdentifier("Register", identifier: "RegisterView") as? RegisterViewController
            
        }

        Common.rootViewController.homeViewController.navigationController?.pushViewController(regVc!, animated: true)
        
    }

    
    /**
    点击保存密码处理
    
    :param: sender <#sender description#>
    */
    @IBAction func onClickSavePasswrd(sender: UIButton) {
        
        if "cbOn" == sender.restorationIdentifier { //不保存密码
            
            cbonBtn.hidden = true
            cboffBtn.hidden = false
            savePassword = false
            
        } else { //保存密码
            
            cbonBtn.hidden = false
            cboffBtn.hidden = true
            savePassword = true
            
        }
    }

}
