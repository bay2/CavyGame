//
//  LeftViewController.swift
//  CavyGame
//
//  Created by JohnLui on 15/4/11.
//  Copyright (c) 2015年 com.lvwenhan. All rights reserved.
//

import UIKit

class LeftViewController: UserLogin, UITableViewDelegate, UITableViewDataSource {
    
    let FullDistance: CGFloat = 0.78  // 左视图占的宽度最大比例
    
    let text1 = Common.LocalizedStringForKey("main_leftview_title_down");
    
    let titlesDictionary = [Common.LocalizedStringForKey("main_leftview_title_down"),
                          //  Common.LocalizedStringForKey("main_leftview_title_mygame"),
                            Common.LocalizedStringForKey("main_leftview_title_sysmsg"),
                            Common.LocalizedStringForKey("main_leftview_title_feedback"),
                            Common.LocalizedStringForKey("main_leftview_title_setting"),
                            Common.LocalizedStringForKey("main_leftview_title_about")]

    let iconMenuDictionary = ["menu_icon_down",
                            //  "menu_icon_mygame",
                              "menu_icon_message",
                              "menu_icon_feedback",
                              "menu_icon_setting",
                               "menu_icon_about",
                              ];
    
    @IBOutlet weak var settingTableView: UITableView!
    @IBOutlet weak var userName: UILabel!
    
    @IBOutlet weak var avatarBtn: UIButton!
    @IBOutlet weak var heightLayoutConstraintOfSettingTableView: NSLayoutConstraint!
    
    var userCenterVc : UserCenterViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingTableView.delegate = self
        settingTableView.dataSource = self
        settingTableView.tableFooterView = UIView()
        settingTableView.backgroundColor = UIColor.clearColor()
        settingTableView.scrollEnabled = false
        
        self.avatarBtn.imageView?.layer.masksToBounds = true
        self.avatarBtn.imageView?.layer.cornerRadius = self.avatarBtn.imageView!.bounds.size.width * 0.5

        self.view.frame = CGRectMake(0, 0, Common.screenWidth * FullDistance, Common.screenHeight)
        
        userName.text = Common.LocalizedStringForKey("LeftView_nikeLabel")
        
        setControlCenter()
         //如果登录过，则自动登录
        let bIsLogin = isLogin()
        if (bIsLogin != nil) && (true == bIsLogin) {
            
            userlogin(nil, passwd: nil,isLogin: { (isLoginSucce, msg) -> () in
                
                if LoginReturn.LoginSucceed == isLoginSucce {
                    
                    self.setAvatarImage()

                    self.UpdateUserName(Common.userInfo.nikename!)
                    
                }
            })
            
        }
    }
    
    func setControlCenter(){
        
        // 把头像 名字 列表居中
        var frame : CGRect
        
        frame = settingTableView.frame
        frame.size.width = Common.screenWidth * FullDistance
        settingTableView.frame = frame
        
        frame = avatarBtn.frame
        frame.origin.x = Common.screenWidth * FullDistance/2 - frame.size.width/2
        avatarBtn.frame = frame

        frame = userName.frame
        frame.origin.x = Common.screenWidth * FullDistance/2 - frame.size.width/2
        userName.frame = frame
    }
    
    /**
    设置头像
    */
    func setAvatarImage() {
        
        var avatarImage = UIImageView()
        avatarImage.setWebImage(Common.userInfo.avatar!, network: false, loadFinish: { () -> () in
            self.avatarBtn.setImage(avatarImage.image, forState: UIControlState.Normal)
        })
    }

    @IBAction func clickAvatar(sender: AnyObject) {
        
        let viewController = Common.rootViewController
        
        if  isLogin()!{
            
            if .UIDeviceResolution_iPhoneRetina4 == resolution() {
                
                userCenterVc = UIStoryboard(name: "UserCenter_iPhone4", bundle: nil).instantiateViewControllerWithIdentifier("UserCenterViewController") as? UserCenterViewController
                
            } else {
                
                userCenterVc = Common.getViewControllerWithIdentifier("UserCenter", identifier: "UserCenterViewController") as? UserCenterViewController
                
            }

            viewController.homeViewController.navigationController!.pushViewController(userCenterVc!, animated: true)
            
        } else {
            
            var regVc : LoginViewController?
            
            if .UIDeviceResolution_iPhoneRetina4 == resolution() {
                
                regVc = UIStoryboard(name: "Login_iPhone4", bundle: nil).instantiateViewControllerWithIdentifier("LoginView") as? LoginViewController
                
            } else {
                
                regVc = Common.getViewControllerWithIdentifier("Login", identifier: "LoginView")  as? LoginViewController
                
            }
                        
            viewController.homeViewController.navigationController!.pushViewController(regVc!, animated: true)
            
        }
        
        viewController.mainTabBarController.tabBar.hidden = true
        viewController.mainTabBarController.selectedIndex = 0
        
        viewController.showHome()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let viewController = Common.rootViewController
        
        switch(titlesDictionary[indexPath.row]){
            
        case Common.LocalizedStringForKey("main_leftview_title_down"):
            var downVc = DownloadViewController()
            viewController.homeViewController!.navigationController?.pushViewController(downVc, animated: true)
            
        case Common.LocalizedStringForKey("main_leftview_title_sysmsg"):
            
            var acVc = Common.getViewControllerWithIdentifier("Notice", identifier: "NoticeView") as! NoticeViewController
            viewController.homeViewController!.navigationController?.pushViewController(acVc, animated: true)
            
        case Common.LocalizedStringForKey("main_leftview_title_feedback"):
            
            var fdvc = Common.getViewControllerWithIdentifier("Feedback", identifier: "FeedbackView") as! FeedbackViewController
            
            viewController.homeViewController!.navigationController?.pushViewController(fdvc, animated: true)
            
        case Common.LocalizedStringForKey("main_leftview_title_setting"):
            
            var setVc = Common.getViewControllerWithIdentifier("Set", identifier: "SetView") as! SetViewController
            
            viewController.homeViewController.navigationController?.pushViewController(setVc, animated: true)
            
            break;

        case Common.LocalizedStringForKey("main_leftview_title_about"):
            
            var aboutVc : AboutTableViewController?
            
            switch resolution() {
                
            case .UIDeviceResolution_iPadStandard:
                
                aboutVc = UIStoryboard(name: "About_iPadRetina", bundle: nil).instantiateViewControllerWithIdentifier("AboutTableView") as? AboutTableViewController
                
            case .UIDeviceResolution_iPadRetina:
                aboutVc = UIStoryboard(name: "About_iPadRetina", bundle: nil).instantiateViewControllerWithIdentifier("AboutTableView") as? AboutTableViewController
                
            case .UIDeviceResolution_iPhoneRetina4:
                aboutVc = UIStoryboard(name: "About_iPhone4", bundle: nil).instantiateViewControllerWithIdentifier("AboutTableView") as? AboutTableViewController
                
            default:
                aboutVc = Common.getViewControllerWithIdentifier("About", identifier: "AboutTableView")  as? AboutTableViewController
            }
            
            
            viewController.homeViewController.navigationController?.pushViewController(aboutVc!, animated: true)
            break;

        default:
            viewController.homeViewController.titleOfOtherPages = titlesDictionary[indexPath.row]
            viewController.homeViewController.performSegueWithIdentifier("showOtherPages", sender: self)
            Common.contactsVC.view.removeFromSuperview()
        }
        
        viewController.showHome()
        
        //使用选择的行恢复默认状态
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titlesDictionary.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("leftViewCell", forIndexPath: indexPath) as! UITableViewCell
        
        cell.backgroundColor = UIColor.clearColor()
        
        if .UIDeviceResolution_iPadRetina == resolution() || .UIDeviceResolution_iPadStandard == resolution() {
            
            var iconImageView = cell.viewWithTag(1) as! UIImageView
            var textLabel = cell.viewWithTag(2) as! UILabel
            
            textLabel.text = titlesDictionary[indexPath.row]
            iconImageView.image = UIImage(named:iconMenuDictionary[indexPath.row])
        
            
        } else {
            
            cell.textLabel!.text = titlesDictionary[indexPath.row]
            cell.imageView?.image = UIImage(named:iconMenuDictionary[indexPath.row])
            
            
            
        }
        
        var view_bg : UIView = UIView()
        view_bg.backgroundColor = UIColor.grayColor()
        cell.selectedBackgroundView = view_bg;
        
        
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        switch resolution() {
            
            case .UIDeviceResolution_iPhoneStandard:
                return 75
            
            case .UIDeviceResolution_iPadRetina:
                return 75
            
            default:
                return 45
        }
        
    }
    
    func UpdateUserName(username : String) {
        userName.text = username
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func Userlogout() {
        
        UpdateUserName(Common.LocalizedStringForKey("main_leftview_not_login"))
        avatarBtn.imageView?.image = UIImage(named: "avatar")
        setIsLogin(false)
    }

}
