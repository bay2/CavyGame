//
//  UserLogin.swift
//  CavyGame
//
//  Created by xuemincai on 15/8/5.
//  Copyright (c) 2015年 com.lvwenhan. All rights reserved.
//

import Foundation
import UIKit

class UserLogin : UIViewController {
    
    enum  LoginReturn {
        
        case LoginSucceed
        case LoginError
        case LoginNetError
    
    }
    
    
    /**
    用户登录
    
    :param: userName 用户名
    :param: passwd   用户密码
    
    :returns: 登录结果
    */
    func userlogin(userName : String?, passwd : String?, isLogin:(isLoginSucce:LoginReturn!, msg : String?)->()) {
        
        var strUserName : String
        var strPasswd : String
        var isRet = false
        
        
        if  nil == userName {
            strUserName = getUserName()
        }
        else {
            strUserName = userName!
        }
        
        if nil == passwd {
            strPasswd = getPasswd()
        } else {
            strPasswd = passwd!
        }
        
        if (strPasswd.isEmpty || strUserName.isEmpty) {
            isLogin(isLoginSucce: LoginReturn.LoginError, msg: nil)
        }
        
        self.setIsLogin(false)
        
        HttpHelper<UserLoginMsg>.loginUser(strUserName, userPassword: strPasswd.md5()) { (result) -> () in
            
            dispatch_async(dispatch_get_main_queue(), {
                
                if nil == result?.msg {
                    
                    isLogin(isLoginSucce: LoginReturn.LoginNetError, msg: nil)
                    return
                    
                }
                
                if "1001" == result?.code! {
                    
                    //记录用户信息
                    Common.userInfo.avatar = result?.data?.avatar
                    Common.userInfo.birthday = result?.data?.birthday
                    Common.userInfo.email = result?.data?.email
                    Common.userInfo.gender = result?.data?.gender
                    Common.userInfo.is_disabled = result?.data?.is_disabled
                    Common.userInfo.last_login_time = result?.data?.last_login_time
                    Common.userInfo.nikename = result?.data?.nikename
                    Common.userInfo.phone = result?.data?.phone
                    Common.userInfo.userid = result?.data?.userid
                    Common.userInfo.username = result?.data?.username
                    Common.userInfo.usertoken = result?.data?.usertoken
                    
                    self.setIsLogin(true)
                    isLogin(isLoginSucce: LoginReturn.LoginSucceed, msg: result?.msg)
                    
                } else {
                    isLogin(isLoginSucce: LoginReturn.LoginNetError, msg: result?.msg)
                }
            })
        }
        
    }
    
    /**
    是否已经登录
    
    :returns: true 登录，false 未登录
    */
    func isLogin()->Bool! {
        
        if (nil == NSUserDefaults.standardUserDefaults().valueForKey("isLogin")) {
            return false
        }
        
        let bIsLogin = NSUserDefaults.standardUserDefaults().valueForKey("isLogin") as! Bool!
        
        return bIsLogin
        
    }
    
    /**
    获取用户名
    
    :returns: 用户名
    */
    func getUserName()->String! {
        
        if nil == NSUserDefaults.standardUserDefaults().valueForKey("username") {
            return ""
        }
        
        return NSUserDefaults.standardUserDefaults().valueForKey("username") as! String!
        
    }
    
    /**
    获取用户密码
    
    :returns: 用户密码
    */
    func getPasswd()->String! {
        
        if nil == NSUserDefaults.standardUserDefaults().valueForKey("password") {
            return ""
        }
        
        return NSUserDefaults.standardUserDefaults().valueForKey("password") as! String!
    }
    
    /**
    是否保存密码
    
    :returns: true 保存，false 不保存
    */
    func isSavePasswd()->Bool! {
        
        if nil == NSUserDefaults.standardUserDefaults().valueForKey("savePassword") {
            return false
        }
        
        return NSUserDefaults.standardUserDefaults().valueForKey("savePassword") as! Bool!
    }
    
    /**
    设置保存密码标志
    
    :param: isSavePasswd true 保存 false 不保存
    */
    func setSavePasswd(isSavePasswd : Bool) {
        NSUserDefaults.standardUserDefaults().setObject(isSavePasswd, forKey: "savePassword")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    /**
    保存密码
    
    :param: passwd 密码
    */
    func savePasswd(passwd: String) {
        NSUserDefaults.standardUserDefaults().setObject(passwd, forKey: "password")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    /**
    删除密码
    */
    func removePasswd() {
        NSUserDefaults.standardUserDefaults().removeObjectForKey("password")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    /**
    保存用户名
    
    :param: userName 用户名
    */
    func saveUserName(userName: String) {
        
        NSUserDefaults.standardUserDefaults().setObject(userName, forKey: "username")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    /**
    设置是否已登录
    
    :param: bIsLogin true 已登录，false 未登录
    */
    func setIsLogin(bIsLogin: Bool) {
        NSUserDefaults.standardUserDefaults().setObject(bIsLogin, forKey: "isLogin")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
}