//
//  FoundPasswordEmailViewController.swift
//  CavyGame
//
//  Created by xuemincai on 15/8/30.
//  Copyright (c) 2015年 com.lvwenhan. All rights reserved.
//

import UIKit

class FoundPasswordEmailViewController: UIViewController {

    @IBOutlet weak var pwd2Text: UITextField!
    @IBOutlet weak var pwdText: UITextField!
    @IBOutlet weak var codeText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var codeImage: UIImageView!
    @IBOutlet weak var finishBtn: UIButton!
    @IBOutlet weak var phoneBarItem: UIBarButtonItem!
    
    var backView: UIViewController?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = Common.LocalizedStringForKey("FoundPasswd")
        
        phoneBarItem.title = Common.LocalizedStringForKey("phoneBarItem")
        
        finishBtn.setTitle(Common.LocalizedStringForKey("finishBtn"), forState: UIControlState.allZeros)
        
        emailText.placeholder = Common.LocalizedStringForKey("emailText")
        codeText.placeholder  = Common.LocalizedStringForKey("sendCode")
        pwdText.placeholder  = Common.LocalizedStringForKey("loginView_password_txt")
        pwd2Text.placeholder  = Common.LocalizedStringForKey("loginView_password2_txt")
        
        codeText.delegate = self
        emailText.delegate = self
        finishBtn.layer.masksToBounds = true
        finishBtn.layer.cornerRadius = Common.btnCornerRadius
        finishBtn.setBackgroundCoclor(UIColor(hexString: "3e76db"), forState: UIControlState.Highlighted)
        
        codeImage.setWebImage(serverAddr + "authority/imageCode?codekey=1", network: true)
        
        
        var tap = UITapGestureRecognizer(target: self, action: "onClickCodeImage:")
        codeImage!.addGestureRecognizer(tap)
        codeImage.userInteractionEnabled = true
        
        
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
        
        codeImage.reloadWebImage(serverAddr + "authority/imageCode?codekey=1", network: true)
        
    }
    
    /**
    点击返回
    
    :param: sender
    */
    @IBAction func onClickBack(sender: UIBarButtonItem) {
        
        self.navigationController?.popToViewController(self.navigationController?.viewControllers[1] as! UIViewController, animated: true)
        
    }

    /**
    点击手机
    
    :param: sender
    */
    @IBAction func onClickPhone(sender: UIBarButtonItem) {
        
        self.navigationController?.popViewControllerAnimated(true)
        
    }
    
    /**
    点击完成
    
    :param: sender
    */
    @IBAction func onClickFinish(sender: UIButton) {
        
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
        
        if pwdText.text.isEmpty {
            
            FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(self.view, withTitle: Common.LocalizedStringForKey("login_enter_passwd"), delayTime: Common.alertDelayTime)
            return
            
        }
        
        if pwd2Text.text.isEmpty {
            
            FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(self.view, withTitle: Common.LocalizedStringForKey("login_enter_passwd"), delayTime: Common.alertDelayTime)
            return
            
        }
        
        if pwd2Text.text != pwdText.text {
            
            FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(self.view, withTitle: Common.LocalizedStringForKey("foundpasswd_err"), delayTime: Common.alertDelayTime)
            return
        }
        
        if 6 > count(pwdText.text) {
            
            FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(self.view, withTitle: Common.LocalizedStringForKey("register_passwd_num_err"), delayTime: Common.alertDelayTime)
            return
        }
        
        
        
        var loadView = FVCustomAlertView.shareInstance.showDefaultLoadingAlertOnView(self.view, withTitle: Common.LocalizedStringForKey("SDRefreshViewRefreshingStateText"), isClickDisappeared: true)
        
        //修改密码
        HttpHelper<CommmonMsgRet>.emailModifyPwd(emailText.text, pwd: pwdText.text.md5(), code: codeText.text) { (result) -> () in
            

            dispatch_async(dispatch_get_main_queue(), {
                
                FVCustomAlertView.shareInstance.hideAlert(loadView!)
                
                if nil == result?.code {
                    
                    FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(self.view, withTitle: Common.LocalizedStringForKey("net_err"), delayTime: Common.alertDelayTime)
                    return
                    
                }
                
                if "1001" != result?.code! {
                    
                    FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(self.view, withTitle: result!.msg!, delayTime: Common.alertDelayTime)
                    return
                    
                }
                
                FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(self.view, withTitle: result!.msg!, delayTime: Common.alertDelayTime)
                
                self.navigationController?.popViewControllerAnimated(true)
            
            })
            
        }
        
        
    }
    
}

extension FoundPasswordEmailViewController : UITextFieldDelegate {
    
    /**
    输入限制
    
    :param: textField <#textField description#>
    :param: range     <#range description#>
    :param: string    <#string description#>
    
    :returns: <#return value description#>
    */
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        if textField == codeText {
            
            
            var toString = textField.text + (string as String)
            
            if 4 < count(toString) {
                
                return false
                
            }
        }
        
        return true
        
    }
    
    
}
