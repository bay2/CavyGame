//
//  HomeViewController.swift
//  CavyGame
//
//  Created by JohnLui on 15/4/10.
//  Copyright (c) 2015年 com.lvwenhan. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, DMDynamicPageViewControllerDelegate, SwipePagerMenuDelegate, UIAlertViewDelegate{
    
    var dynamicPageController : DMDynamicViewController!
    var swipeMenuView : SwipePagerMenu!
    var currentPage:Int = 0
    var userAPNsMessage : NSNotification?
    var viewControllers = NSMutableArray()

    var titleOfOtherPages = ""
    
    @IBOutlet var panGesture: UIPanGestureRecognizer!
    //@IBOutlet weak var LayoutConstraintOfselLineTag: NSLayoutConstraint!
   
    @IBOutlet weak var lifeBarBtn: UIBarButtonItem! // 此处需要保留 否则在7.1上运行异常
    @IBOutlet weak var rightBarBtn: UIBarButtonItem!
    
    var viewController1 : RecommendationVC!
    var viewController2 : RankingVC!
    var viewController3 : ClassificationTbVC!
    var viewController4 : PrefectureViewController!
    
    var loadDataCnt : Int = 0    // 加载推荐 分类 排行  成功的数量
    let loadDataMaxCnt : Int = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置中间 segmentView 视图
    
        var imagView = UIImageView(image: UIImage(named: "logo"))
        
  
        
        self.navigationItem.titleView = imagView
        self.navigationItem.titleView?.backgroundColor = UIColor.clearColor()
        self.navigationController!.navigationBar.translucent = false; // 必须设置 否则swipeMenuView 不显示    
        initSwipeMenu()
        initPageController()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showNotificationView:", name: Common.notifyShowView, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "ShowAPNsAlertView:", name: Common.notifyAPNSShowView, object: nil)
        
    }

    @IBAction func onClickShowLeft(sender: UIBarButtonItem) {
        
        Common.rootViewController.clickShowLeft()
    }

    func initLeftBtn(target : AnyObject?, action: Selector){
        
        var btn : UIButton = UIButton(frame: CGRectMake(0.0, 0.0, 44.0, 44.0))
        btn.setImage(UIImage(named: "icon_menu"), forState: UIControlState.Normal)
        btn.imageEdgeInsets = UIEdgeInsetsMake(0, -40, 0, 0)
        
        btn.addTarget(target, action: action, forControlEvents: UIControlEvents.TouchUpInside)
        
        var leftBtn = UIBarButtonItem(customView: btn)
        
        self.navigationItem.leftBarButtonItem = leftBtn
    }
    
    func initSwipeMenu(){
        
        let menuTitle = [ Common.LocalizedStringForKey("menu_btn1"),
                          Common.LocalizedStringForKey("menu_btn2"),
                          Common.LocalizedStringForKey("menu_btn3"),
                          Common.LocalizedStringForKey("menu_btn4")];
        let menuViewFrame = CGRectMake(0.0, 0.0, Common.screenWidth, SwipePagerMenu.menuTotalHight)
        swipeMenuView = SwipePagerMenu(arrTitle: menuTitle,frame: menuViewFrame)
        swipeMenuView.delegate = self

        println(swipeMenuView.frame.height)
        self.view.addSubview(swipeMenuView)
    }
    
    func showNotificationView(notification:NSNotification){
        
        var userInfo = notification.userInfo
        let pushType = userInfo!["pushType"] as? String
        
        if pushType == nil {
            return;
        }
        
        switch pushType! {
            
            case "game" :
                
                var gameVc = Common.getViewControllerWithIdentifier("AppInfo", identifier: "AppInfoView") as! AppInfoViewController
                gameVc.gameId = userInfo!["gameId"] as! String
                self.navigationController!.pushViewController(gameVc, animated: true)
                
                break
            
            case "sysMessage" :
                var noticeDetail = Common.getViewControllerWithIdentifier("Notice", identifier: "NoticeDetail") as! NoticeDetailViewController
                
                noticeDetail.navigationItem.title = userInfo!["title"] as? String
                noticeDetail.loadhttp = userInfo!["url"] as? String

                self.navigationController?.pushViewController(noticeDetail, animated: true)
                break
            
            case "updateApp" :
                break
            
            case "prefecture" :
                var prefectureID = userInfo!["prefectureId"] as! String
                var prefectureStyle = userInfo!["style"] as! String
                var title = userInfo!["title"] as! String
                showPrefecture(prefectureID.toInt()!, prefectureStyle: prefectureStyle, title: title)
                
                
                break
            
            default:
                break
            
        }
        
    }
    
    func showPrefecture(prefectureID : Int, prefectureStyle : String, title : String) {
        
        // 显示专题
        
        var preListVc : PrefecturListViewController!
        
        switch resolution() {
            
        case .UIDeviceResolution_iPhoneRetina4:
            preListVc = UIStoryboard(name: "Prefecture_iPhone4", bundle: nil).instantiateViewControllerWithIdentifier("PrefectureListView") as! PrefecturListViewController
            
        case .UIDeviceResolution_iPadRetina:
            preListVc = UIStoryboard(name: "Prefecture_iPadRetina", bundle: nil).instantiateViewControllerWithIdentifier("PrefectureListView") as! PrefecturListViewController
            
        case .UIDeviceResolution_iPadStandard:
            preListVc = UIStoryboard(name: "Prefecture_iPadRetina", bundle: nil).instantiateViewControllerWithIdentifier("PrefectureListView") as! PrefecturListViewController
            
        default:
            preListVc = Common.getViewControllerWithIdentifier("Prefecture", identifier: "PrefectureListView") as! PrefecturListViewController
            
        }
        
        
        preListVc.preId = prefectureID
        preListVc.styleType = prefectureStyle
        preListVc.navigationItem.title = title
        
        self.navigationController?.pushViewController(preListVc, animated: true)
    }
    
    func swipePagerMenu(sender: UIButton){
        dynamicPageController?.currentPage = sender.tag
    }
    
    // MARK: - DMDynamicPageViewControllerDelegate begin
    func pageViewController(pageController: DMDynamicViewController, didSwitchToViewController viewController: UIViewController){
        
    }
    
    func pageViewController(pageController: DMDynamicViewController, didChangeViewControllers viewControllers: Array<UIViewController>){
        
    }
    
    // 翻页完成后回调
    func pageViewController(pageController: DMDynamicViewController){
        
        self.swipeMenuView.pageChange(pageController.currentPage)
    }
    // MARK: - DMDynamicPageViewControllerDelegate end

    func initPageController() {
        
        viewController1 = RecommendationVC()
        viewController2 = RankingVC()
        viewController3 = ClassificationTbVC()
        viewController4 = Common.getViewControllerWithIdentifier("Prefecture", identifier: "PrefectureView") as? PrefectureViewController
        
        viewController1.view.backgroundColor = Common.tableBackColor
        viewController2.view.backgroundColor = Common.tableBackColor
        viewController3.view.backgroundColor = Common.tableBackColor

        
        let viewControllers = [viewController1, viewController2, viewController3, viewController4]
        dynamicPageController = DMDynamicViewController(viewControllers: viewControllers)
        
        self.addChildViewController(dynamicPageController)
        
        var frame = dynamicPageController.view.frame
        frame.origin.y = swipeMenuView.frame.origin.y + SwipePagerMenu.menuTotalHight
        frame.size.height = frame.height - frame.origin.y
        dynamicPageController.view.frame = frame
        self.view.addSubview(dynamicPageController.view)
        
        println(dynamicPageController.view.frame.origin.y)
        println(viewController1.view.frame.origin.y)
        println(viewController1.tableView.frame.origin.y)
        
        dynamicPageController.delegate = self;
        return
    }
    
    override func viewWillAppear(animated: Bool) // Called when the view has been fully transitioned onto the screen. Default does nothing
    {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().postNotificationName(Common.notifyAdd_Page1, object: nil)
        NSNotificationCenter.defaultCenter().postNotificationName(Common.notifyAdd_Page2, object: nil)
        NSNotificationCenter.defaultCenter().postNotificationName(Common.notifyAdd_Page3, object: nil)
    }
    
    override func viewDidDisappear(animated: Bool)
    {
        super.viewDidDisappear(animated)
        
        NSNotificationCenter.defaultCenter().postNotificationName(Common.notifyRemove_PrePage + Common.notifyAdd_Page1, object: nil)
        NSNotificationCenter.defaultCenter().postNotificationName(Common.notifyRemove_PrePage + Common.notifyAdd_Page2, object: nil)
        NSNotificationCenter.defaultCenter().postNotificationName(Common.notifyRemove_PrePage + Common.notifyAdd_Page3, object: nil)
    }
    
    func enableSwipeMenu(enable : Bool){
        
        swipeMenuView.enableBtn(enable)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func ShowAPNsAlertView (notification : NSNotification) {
        
        userAPNsMessage = notification
        println("\(notification.userInfo)")
        let aps : Dictionary<String, AnyObject> = notification.userInfo!["aps"] as! Dictionary<String, AnyObject>
        let alertMsg : String = aps["alert"] as! String
        let pushType = notification.userInfo!["pushType"] as? String
        
        if ("updateApp" == pushType) {
            CheckUpdate.shareInstance.checkUpdate();
            return
        }
        
        let apnAlert = UIAlertView(title: Common.LocalizedStringForKey("alert_Location_APNs_Title"), message: alertMsg, delegate: self, cancelButtonTitle: nil, otherButtonTitles: Common.LocalizedStringForKey("alert_Location_ButtonDismissTitle"), Common.LocalizedStringForKey("alert_Location_ButtonViewTitle"))
        
        //先初始化rootViewController
        Common()
        
        apnAlert.show()
        
    }
    
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        
        if (buttonIndex == 1) {
            
            showNotificationView(userAPNsMessage!)

            alertView.hidden = true

            
        } else  {
            alertView.hidden = true
        }
    }
}
