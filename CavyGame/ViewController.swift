//
//  ViewController.swift
//  CavyGame
//
//  Created by JohnLui on 15/4/10.
//  Copyright (c) 2015年 com.lvwenhan. All rights reserved.
//

import UIKit
import CoreLocation
import AVFoundation

class ViewController: UIViewController,AVAudioPlayerDelegate {
    
    var mainTabBarController: MainTabBarController!
    var tapGesture: UITapGestureRecognizer!
    
    var homeNavigationController: UINavigationController!
    var homeViewController: HomeViewController!
    var leftViewController: LeftViewController!
    var mainView: UIView! // 构造主视图。实现 UINavigationController.view 和 HomeViewController.view 一起缩放。
    
    var blackCover: UIView!
    
    var kLeftCenterX : CGFloat = 30 //左侧初始偏移量
    var isPostOpenApp = false
    
    var audioPlayer : AVAudioPlayer!
    
    var loadDataCnt : Int!  // 加载完推荐 排行 分类的计数
    let maxLoadDataCnt  = 3 // 加载完推荐 排行 分类的最大计数
    
    var _scalef : CGFloat = 0  //实时横向位移
    let FullDistance: CGFloat = 0.78  // 左视图占的宽度最大比例
    let vSpeedFloat : CGFloat = 0.7     // 滑动速度
    let kLeftScale : CGFloat = 0.7 //左侧初始缩放比例
    let kLeftAlpha : CGFloat = 0.9  //左侧蒙版的最大值
    let kMainPageScale  : CGFloat = 0.8  //打开左侧窗时，右视）缩放比例
    
    var closedLeftView = true
    var leftBarBtn : UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadDataCnt = 0

        // 给主视图设置背景
        /*
        let imageView = UIImageView(image: UIImage(named: "back"))
        imageView.frame = UIScreen.mainScreen().bounds
        self.view.addSubview(imageView)*/
        self.view.backgroundColor = UIColor(hexString: "393939")
        //初始化数据库管理
        var sqliteInit = Down_Interface.getInstance()
        sqliteInit.sqliteInit()
        
        // 通过 StoryBoard 取出 LeftViewController
        
        switch resolution() {
            
            case .UIDeviceResolution_iPadRetina:
                leftViewController = UIStoryboard(name: "Main_iPadRetina", bundle: nil).instantiateViewControllerWithIdentifier("LeftViewController")  as! LeftViewController
            
            case .UIDeviceResolution_iPadStandard:
                leftViewController = UIStoryboard(name: "Main_iPadRetina", bundle: nil).instantiateViewControllerWithIdentifier("LeftViewController")  as! LeftViewController
            
            
            default:
                leftViewController = Common.getViewControllerWithIdentifier("Main", identifier: "LeftViewController") as! LeftViewController
            
        }
        
        //设置左侧tableview的初始位置和缩放系数
        leftViewController.view.transform = CGAffineTransformMakeScale(kLeftScale, kLeftScale);
        leftViewController.view.center = CGPointMake(kLeftCenterX, Common.screenHeight * 0.5);
        
        self.view.addSubview(leftViewController.view)

        // 增加黑色遮罩层，实现视差特效
        blackCover = UIView(frame: CGRectOffset(self.view.frame, 0, 0))
        blackCover.backgroundColor = UIColor.blackColor()
        self.view.addSubview(blackCover)
        
        // 通过 StoryBoard 取出 HomeViewController 的 view，放在背景视图上面
        mainView = UIView(frame: self.view.frame)
        
        let nibContents = NSBundle.mainBundle().loadNibNamed("MainTabBarController", owner: nil, options: nil)
        mainTabBarController = nibContents.first as! MainTabBarController
        
        let tabBarView = mainTabBarController.view
        mainView.addSubview(tabBarView)
        
        homeNavigationController =  Common.getViewControllerWithIdentifier("Main", identifier: "HomeNavigationController") as! UINavigationController
        
        homeViewController = homeNavigationController.viewControllers.first as! HomeViewController
                
        tabBarView.addSubview(homeViewController.navigationController!.view)
        tabBarView.addSubview(homeViewController.view)
        
        tabBarView.bringSubviewToFront(mainTabBarController.tabBar)
        
        self.view.addSubview(mainView)
        
        //homeViewController.initLeftBtn(self, action: Selector("clickShowLeft"))
        homeViewController.navigationItem.rightBarButtonItem?.action = Selector("clickShowLeft")
        homeViewController.navigationItem.rightBarButtonItem?.action = Selector("showRight")
        
        // 绑定 UIPanGestureRecognizer
        let panGesture = homeViewController.panGesture
        panGesture.addTarget(self, action: Selector("pan:"))
        mainView.addGestureRecognizer(panGesture)
        
        // 生成单击收起菜单手势
        tapGesture = UITapGestureRecognizer(target: self, action: "showHome")
        
        CheckUpdate.shareInstance.checkUpdate();
        
        BDLocationManager().sharedManager().statusDelegate = self
        BDLocationManager().sharedManager().startLocation()
        
        playMp3()
        
        //在非wifi下用户选择了继续下载
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "checkGameUpdate:", name: Common.notifyLoadFinishData, object: nil)
    }
    
    func playMp3(){
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),{
            
            var audioSessionError = NSErrorPointer()
            
            var audioSession = AVAudioSession.sharedInstance()
            
            // 这样后台播放就不会影响到别的程序播放音乐了
            if audioSession.setCategory(AVAudioSessionCategoryPlayback, withOptions:AVAudioSessionCategoryOptions.MixWithOthers, error: audioSessionError){
                println("Successfully set the audio session.")
            }else{
                println("Could not set the audio session")
            }
            
            var fileData = NSData.dataWithContentsOfMappedFile(NSBundle.mainBundle().pathForResource("tmp", ofType: "mp3")!) as! NSData
            
            self.audioPlayer = AVAudioPlayer(data:fileData, error:audioSessionError)
            self.audioPlayer.volume = 0
            
            if let _ = self.audioPlayer{
                self.audioPlayer.delegate = self
                self.audioPlayer.numberOfLoops = -1
                
                if self.audioPlayer.prepareToPlay() && self.audioPlayer.play(){
                    println("Successfully started playing...")
                }else{
                    println("Failed to play.")
                }
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // 响应 UIPanGestureRecognizer 事件
    func pan(rec: UIPanGestureRecognizer) {
        
        var point = rec.translationInView(self.view)
        
        _scalef = point.x * vSpeedFloat + _scalef
        
        var needMoveWithTap = true //是否还需要跟随手指移动
        
        if (((mainView.frame.origin.x <= 0) && (_scalef <= 0)) || ((mainView.frame.origin.x >= (Common.screenWidth*FullDistance )) && (_scalef >= 0)))
        {
            //边界值管控
            _scalef = 0;
            needMoveWithTap = false;
        }
        
        //根据视图位置判断是左滑还是右边滑动
        if (needMoveWithTap && (rec.view!.frame.origin.x >= 0) && (rec.view!.frame.origin.x <= (Common.screenWidth*FullDistance)))
        {
            var recCenterX = rec.view!.center.x + point.x * vSpeedFloat;
            if (recCenterX < Common.screenWidth * 0.5 - 2) {
                recCenterX = Common.screenWidth * 0.5;
            }
            
            var recCenterY = rec.view!.center.y;
            
            rec.view!.center = CGPointMake(recCenterX,recCenterY);
            
            //scale 1.0~kMainPageScale
            var scale = 1 - (1 - kMainPageScale) * (rec.view!.frame.origin.x / (Common.screenWidth*FullDistance))

            rec.view!.transform = CGAffineTransformScale(CGAffineTransformIdentity,scale, scale);
            rec.setTranslation(CGPointMake(0, 0), inView: self.view)
            
            var leftTabCenterX = kLeftCenterX + ((Common.screenWidth*FullDistance) * 0.5 - kLeftCenterX) * (rec.view!.frame.origin.x / (Common.screenWidth*FullDistance))


            //leftScale kLeftScale~1.0
            var leftScale = kLeftScale + (1 - kLeftScale) * (rec.view!.frame.origin.x / (Common.screenWidth*FullDistance))
            
            leftViewController.view.center = CGPointMake(
                leftTabCenterX,
                Common.screenHeight * 0.5)
            leftViewController.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, leftScale, leftScale)
            
            //tempAlpha kLeftAlpha~0
            var tempAlpha = kLeftAlpha - kLeftAlpha * (rec.view!.frame.origin.x / (Common.screenWidth*FullDistance));
            
            blackCover.alpha = tempAlpha
        }else{
            //超出范围，
            if (mainView.frame.origin.x < 0)
            {
                showHome()
                _scalef = 0
            }
            else if (mainView.frame.origin.x > (Common.screenWidth*FullDistance))
            {
                showLeft()
                _scalef = 0
            }
        }
        
        //手势结束后修正位置,超过约一半时向多出的一半偏移
        if rec.state == UIGestureRecognizerState.Ended {
            
            let vCouldChangeDeckStateDistance : CGFloat = (Common.screenWidth*FullDistance) / 2.0 - 40 //滑动距离大于此数时，状态改变（关--》开，或者开--》关

            if (fabs(_scalef) > vCouldChangeDeckStateDistance)
            {
                if (self.closedLeftView)
                {
                    showLeft()
                }
                else
                {
                    showHome()
                }
            }
            else
            {
                if (self.closedLeftView)
                {
                    showHome()
                }
                else
                {
                    showLeft()
                }
            }
            _scalef = 0;
        }
    }
    
    // 封装三个方法，便于后期调用
    
    // 展示左视图
    func showLeft() {
        closedLeftView = false
        mainView.addGestureRecognizer(tapGesture)
        mainView.addGestureRecognizer(homeViewController.panGesture)

        doTheAnimate("left")
        homeNavigationController.popToRootViewControllerAnimated(true)
        homeViewController.dynamicPageController.containerScrollView.scrollEnabled = false
        homeViewController.enableSwipeMenu(false)
        NSNotificationCenter.defaultCenter().postNotificationName(Common.notifyShowLeftView, object: nil)
        
        if  nil != homeViewController.navigationItem.leftBarButtonItem {
            
            leftBarBtn = homeViewController.navigationItem.leftBarButtonItem
            homeViewController.navigationItem.leftBarButtonItem = nil
            
        }
        
    }
    
    func clickShowLeft() {
        
        if mainView.frame.origin.x > 0{
            showHome()
        }else{
            showLeft()
        }
    }
    
    // 展示主视图
    func showHome() {
        closedLeftView = true
        mainView.removeGestureRecognizer(tapGesture)
        mainView.removeGestureRecognizer(homeViewController.panGesture)

        doTheAnimate("home")
        homeViewController.dynamicPageController.containerScrollView.scrollEnabled = true
        homeViewController.enableSwipeMenu(true)
        NSNotificationCenter.defaultCenter().postNotificationName(Common.notifyShowHomeView, object: nil)
        
        if nil != leftBarBtn {
            
            homeViewController.navigationItem.leftBarButtonItem = leftBarBtn
            
        }
        
    }
    // 展示搜索视图
    func showRight() {
        
        var searchView  = Common.getViewControllerWithIdentifier("Search", identifier: "SearchView") as! SearchViewController
        
        Common.rootViewController.homeViewController.navigationController?.pushViewController(searchView, animated: true)
        return;
    }
    
    // 执行试图展示
    func doTheAnimate(showWhat: String) {
        UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
        
            if showWhat == "left" {

                let kMainPageCenter  = CGPointMake(Common.screenWidth + Common.screenWidth * self.kMainPageScale / 2.0 - Common.screenWidth*(1-self.FullDistance), Common.screenHeight / 2)  //打开左侧窗时，中视图中心点
                
                self.mainView.transform = CGAffineTransformScale(CGAffineTransformIdentity,self.kMainPageScale,self.kMainPageScale);
                self.mainView.center = kMainPageCenter;

                self.leftViewController.view.center = CGPointMake(Common.screenWidth*self.FullDistance * 0.5, Common.screenHeight * 0.5);
                self.leftViewController.view.transform = CGAffineTransformScale(CGAffineTransformIdentity,1.0,1.0);
            }else{

                self.mainView.transform = CGAffineTransformScale(CGAffineTransformIdentity,1.0,1.0);
                self.mainView.center = CGPointMake(Common.screenWidth / 2, Common.screenHeight / 2);
                
                self.leftViewController.view.center = CGPointMake(self.kLeftCenterX, Common.screenHeight * 0.5);
                self.leftViewController.view.transform = CGAffineTransformScale(CGAffineTransformIdentity,self.kLeftScale,self.kLeftScale);
            }
            
            self.blackCover.alpha = showWhat == "home" ? 1 : 0
        
             }, completion: nil)
    }
    
    func postOpenApp(lbs : String){
        if (!isPostOpenApp) {
            isPostOpenApp = true;
            
            HttpHelper<CommmonMsgRet>.logToServer(LogCode.OPENAPP.rawValue, msg : "OPEN_IOS_APP", lbs : lbs, completionHandlerRet: { (result) -> () in
                
                println("postOpenApp")
            })
         }
    }
    
    // 如果推荐 排行 分类的数据加载完后 检查已经下载完的游戏中是否有需要更新的
    func checkGameUpdate(notification:NSNotification){
       
        loadDataCnt = loadDataCnt + 1
        
        if loadDataCnt > maxLoadDataCnt{
            return
        }
        
        if loadDataCnt == maxLoadDataCnt{
            for item in DownloadManager.getInstance().finishedItems {
                if !item.isCheckUpdate{
                    loadGameDetailsData(item.gameid)
                }
            }
        }
    }
    
    /**
    加载游戏详情数据
    */
    func loadGameDetailsData(gameId : String) {
        
        HttpHelper<GameDetailsInfo>.getGameDetailsInfo(gameId, completionHandlerRet: { (result) -> () in
            
            if "1001" != result?.code {
                
                return
                
            }
           // GameDetailsInfoData
            var gameDetailsInfo : GameDetailsInfoData = result!.data!
            
            DownloadManager.getInstance().needUpdate(gameDetailsInfo.gameid, version: gameDetailsInfo.version, downUrl : gameDetailsInfo.downurl)
        })
    }
}

extension ViewController : LocationManagerStatus{
    
    func getLocationSuccess(location:CLLocation){
        
        var lbs = String(format: "%f,%f", location.coordinate.longitude, location.coordinate.latitude)

        BDLocationManager().sharedManager().stopLocation()
        
        self.postOpenApp(lbs)
    }
    
    /**
    定位失败
    */
    func getLocationFailure(){
        self.postOpenApp("")
    }
    
    /**
    如果定位服务被禁止
    */
    func deniedLocation(){
        
        dispatch_async(dispatch_get_main_queue(), {
            
//            let alvertView = UIAlertView(title: Common.LocalizedStringForKey("alert_Location_Title"), message: Common.LocalizedStringForKey("alert_Location_msg"), delegate: nil, cancelButtonTitle: Common.LocalizedStringForKey("alert_Location_cancelButtonTitle"))
//            
//            alvertView.show();
            
            self.postOpenApp("")
        })
    }
}
