//
//  AppDelegate.swift
//  CavyGame
//
//  Created by JohnLui on 15/4/10.
//  Copyright (c) 2015年 com.lvwenhan. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WXApiDelegate {

    var window: UIWindow?
    var notifyShowViewInfo : [NSObject : AnyObject]?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        TestinAgent.init("c31d01e3fd7df3e26f48339863aa781c", channel: "1", config: TestinConfig.defaultConfig())
        // 改变 StatusBar 颜色
        application.statusBarStyle = UIStatusBarStyle.LightContent
        
        // 改变 navigation bar 的背景色
        var navigationBarAppearace = UINavigationBar.appearance()
        
        var shadowImage = UIImageView(color: Common.TitleBarColor!)
        shadowImage.frame = CGRectMake(0, 0, Common.screenWidth, 1)
//        navigationBarAppearace.setBackgroundImage(shadowImage.image, forBarMetrics: UIBarMetrics.Default)
        navigationBarAppearace.shadowImage = shadowImage.image
        

        navigationBarAppearace.barTintColor = Common.TitleBarColor
        
        navigationBarAppearace.tintColor = UIColor.whiteColor()
        navigationBarAppearace.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
        
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        
        initConfig()
        
        if 8.0 <= Common.getDeviceIosVersion() {
            
            //ios 8 注册 apns
            let notificationSettings = UIUserNotificationSettings(forTypes: UIUserNotificationType.Alert | UIUserNotificationType.Sound | UIUserNotificationType.Badge, categories: nil)
            
            UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
            UIApplication.sharedApplication().registerForRemoteNotifications()
            
            
        } else {
            
            //ios 7 注册 apns
            UIApplication.sharedApplication().registerForRemoteNotificationTypes(UIRemoteNotificationType.Sound | UIRemoteNotificationType.Alert | UIRemoteNotificationType.Badge)
            
        }
        
        APService.setupWithOption(launchOptions)
        
        WXApi.registerApp("wx9c124a9cacdca4ed")
        
        if launchOptions != nil {
            
            var userInfoNotification: AnyObject? = launchOptions![UIApplicationLaunchOptionsRemoteNotificationKey]
            
            if (userInfoNotification != nil) {
                notifyShowViewInfo = userInfoNotification as? [NSObject: AnyObject]
            }
        }
    
        return true

    }
    
    func initConfig() {
        
        var switchOn = NSUserDefaults.standardUserDefaults().valueForKey("install") as? Bool
        if switchOn == nil {
            NSUserDefaults.standardUserDefaults().setObject(true, forKey: "install")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
        switchOn = NSUserDefaults.standardUserDefaults().valueForKey("wifi")  as? Bool
        
        if switchOn == nil {
            NSUserDefaults.standardUserDefaults().setObject(true, forKey: "wifi")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }

    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        if notifyShowViewInfo != nil {
                        
            NSNotificationCenter.defaultCenter().postNotificationName(Common.notifyShowView, object: nil, userInfo: notifyShowViewInfo)
            notifyShowViewInfo = nil
            
        }
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        
        return WXApi.handleOpenURL(url, delegate: self)
        
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        
        return WXApi.handleOpenURL(url, delegate: self)
        
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        
        APService.registerDeviceToken(deviceToken)
        
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        
        println("Failed to get token, error: \(error)")
        
    }
    
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        
        if (application.applicationState == UIApplicationState.Inactive) {
            
            NSNotificationCenter.defaultCenter().postNotificationName(Common.notifyShowView, object: nil, userInfo: userInfo)
            notifyShowViewInfo = nil

        } else if (application.applicationState == UIApplicationState.Active) {
            NSNotificationCenter.defaultCenter().postNotificationName(Common.notifyAPNSShowView, object: nil, userInfo: userInfo)
            notifyShowViewInfo = nil
        }
        
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        
        application.cancelAllLocalNotifications()
        
        APService.handleRemoteNotification(userInfo)
        
    }
    
}

