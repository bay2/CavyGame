//
//  AppInfoViewController.swift
//  CavyGame
//
//  Created by xuemincai on 15/8/18.
//  Copyright (c) 2015年 com.lvwenhan. All rights reserved.
//

import UIKit

class AppInfoViewController: UIViewController, UIAlertViewDelegate {
    
    @IBOutlet weak var shareBarBtn: UIBarButtonItem!
    @IBOutlet weak var gameInfoTableView: UITableView!
    @IBOutlet weak var down: GameInfoDownloadBtn!
    var gameId : String = ""
    
    var gameDetailsInfo : GameDetailsInfoData?
    var reviewArray : Array<ReViewInfoData> = Array<ReViewInfoData>()
    var gameTitleCell : GameTitleTableViewCell?
    var gameRecommendCell : GameRecommendTableViewCell?
    var kbText : KeyboardTextField?
    var reviewCell : GameReviewInfoTableViewCell?

    var itemInfo : GameSubInfo = GameSubInfo()
    var dimBackground = UIView(frame: CGRectMake(0, 0, Common.screenWidth, Common.screenHeight))
    
    var pageNum = 1
    let pagesize = 10
    var alvertView : UIAlertView?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = Common.LocalizedStringForKey("appinfo_title9")
        
        gameInfoTableView.fd_debugLogEnabled = true
        gameInfoTableView.delegate = self
        gameInfoTableView.dataSource = self
        
        gameInfoTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        shareBarBtn.enabled = false
        down.enabled = false
        
        //注册cell
        
        if .UIDeviceResolution_iPhoneRetina4 == resolution() {
            
            gameInfoTableView.registerNib(UINib(nibName: "GameTitleTableViewCell_iPhone4", bundle:nil), forCellReuseIdentifier: "GameTitleTableViewCell")
            
        } else {
            gameInfoTableView.registerNib(UINib(nibName: "GameTitleTableViewCell", bundle:nil), forCellReuseIdentifier: "GameTitleTableViewCell")
        }
        
        gameInfoTableView.registerNib(UINib(nibName: "GameImageTableViewCell", bundle:nil), forCellReuseIdentifier: "GameImageTableViewCell")
        
        gameInfoTableView.registerNib(UINib(nibName: "GameRecommendTableViewCell", bundle:nil), forCellReuseIdentifier: "GameRecommendTableViewCell")
        
        gameInfoTableView.registerNib(UINib(nibName: "GameReviewTableViewCell", bundle:nil), forCellReuseIdentifier: "GameReviewTableViewCell")
        
        gameInfoTableView.registerNib(UINib(nibName: "GameAppInfoTableViewCell", bundle:nil), forCellReuseIdentifier: "GameAppInfoTableViewCell")
        
        gameInfoTableView.registerNib(UINib(nibName: "GameReviewInfoTableViewCell", bundle:nil), forCellReuseIdentifier: "GameReviewInfoTableViewCell")
        
        gameInfoTableView.registerNib(UINib(nibName: "UpdateInfoTableViewCell", bundle: nil), forCellReuseIdentifier: "UpdateInfoTableViewCell")
        
        // 下拉刷新上拉加载更多
        MJRefreshAdapter.setupRefreshHeader(gameInfoTableView, target: self, action: "loadGameDetailsData")
        MJRefreshAdapter.setupRefreshFoot(gameInfoTableView, target: self, action: "loadGameReviewInfo")
        
        //加载游戏详情信息
        loadGameDetailsData()
        
        //加载评论数据
        loadGameReviewInfo()
        
        //创建评论输入控件
        dimBackground.backgroundColor = UIColor.clearColor()
        
        kbText = KeyboardTextField(view: self.view)
        kbText?.hidden = true
        kbText?.textField?.delegate = self
        kbText?.delegate = self
        kbText?.textField?.placeholder = Common.LocalizedStringForKey("reviewplaceholder")
        kbText?.button?.setTitle(Common.LocalizedStringForKey("sendBtn"), forState: UIControlState.Normal)
        kbText?.button?.setTitleColor(UIColor(hexString: "568ae8"), forState: UIControlState.Normal)
        
        dimBackground.addSubview(kbText!)
        
        self.view.removeGestureRecognizer(Common.rootViewController.tapGesture)
        
        initDownBtn()
        // Do any additional setup after loading the view.
        
    }
    
    /**
    游戏简介cell大小
    
    :param: text 简介信息
    */
    func getRecommendCellHight(text : NSString) -> CGFloat {
        
        var label = UILabel()
        
        label.text = text as String
        label.font = UIFont(name: "STHeitiSC-Light", size: 13)
        
        label.numberOfLines = 0
        
        var txtSize : CGSize = CGSize(width: gameInfoTableView.frame.width - 24, height: 130)
        
        var attributedString : NSMutableAttributedString = NSMutableAttributedString(string: text as String)
        
        var paragraphStyle : NSMutableParagraphStyle = NSMutableParagraphStyle()
        
        paragraphStyle.lineSpacing = 6
        
        attributedString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, text.length))
        
        label.attributedText = attributedString
        
        txtSize = text.textSizeWithFont(label.font, constrainedToSize: CGSize(width: txtSize.width, height: CGFloat(MAXFLOAT)))
        
        label.frame.size = txtSize
        
        label.sizeToFit()

        return label.frame.height + 58.6
        
    }
    
    /**
    评论cell大小
    
    :param: text 评论信息
    */
    func getContentCellHight(text : NSString) -> CGFloat {
        
        var label = UILabel()
        
        label.font = UIFont(name: "STHeitiSC-Light", size: 13)
        label.numberOfLines = 0
        label.text = text as String
        
        var txtSize : CGSize = CGSize(width: gameInfoTableView.frame.width - 24, height: 130)
        
        var attributedString : NSMutableAttributedString = NSMutableAttributedString(string: text as String)
        
        var paragraphStyle : NSMutableParagraphStyle = NSMutableParagraphStyle()
        
        paragraphStyle.lineSpacing = 1
        
        attributedString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, text.length))
        
        label.attributedText = attributedString
        
        txtSize = text.textSizeWithFont(label.font, constrainedToSize: CGSize(width: txtSize.width, height: CGFloat(MAXFLOAT)))
        
        label.frame.size = txtSize
        
        label.sizeToFit()
        
        var height = label.frame.height
        
        return height + 84
    }
    
    

    /**
    下载按钮
    */
    func initDownBtn(){
        
        self.down.setButtonImageStatus(DownBtnStatus_OC.STATUS_Down)
        
        self.down.initBnt()
        self.down.layer.masksToBounds = false
        
        down.downPress.textColor = UIColor.whiteColor()
        
        if .UIDeviceResolution_iPhoneRetina4 != resolution() {
            
            down.downPress.textAlignment = NSTextAlignment.Left
            
            if .UIDeviceResolution_iPhoneRetina55  == resolution() {
                
                down.downPress.frame.origin.x = down.frame.width / 2 - 5                
                
            } else if .UIDeviceResolution_iPadRetina  == resolution() {
                
                down.downPress.frame.origin.x = down.frame.width / 1.6
                
            } else {
                down.downPress.frame.origin.x = down.frame.width / 4 + 20
            }
            
            
        } else {
            
            if Common.getDeviceIosVersion() >= 8.0 {
                
                down.downPress.textAlignment = NSTextAlignment.Left
                
                down.downPress.frame.origin.x = down.frame.width / 4
                
            }
            
        }
        
        
        if self.itemInfo.gameid != nil{
            
            self.down.itemInfo = itemInfo
            
        }else{
            var downInterFace = Down_Interface.getInstance()
            
            var downItem = downInterFace.downFishItems_gameid(gameId)
            if downItem != nil{
                // "gamename", "version","downurl","pageName","filesize","icon","gameid"
                self.itemInfo.gamename = downItem.title
                self.itemInfo.version = downItem.version
                self.itemInfo.downurl = downItem.downurl
                self.itemInfo.packpagename = downItem.packagename
                self.itemInfo.filesize = String(downItem.size)
                self.itemInfo.icon = downItem.icon
                self.itemInfo.gameid = downItem.gameid
                
                self.down.itemInfo = self.itemInfo
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
    点击分享游戏
    
    :param: sender 
    */
    @IBAction func shareGame(sender: UIBarButtonItem) {
        
        var dopActWechat = DOPAction(name: Common.LocalizedStringForKey("dopActWechat"), iconName: "wx_logo") { () -> Void in
            self.shareGameInfoToWx(0)
        }
        
        var dopActWxFriends = DOPAction(name: Common.LocalizedStringForKey("dopActWxFriends"), iconName: "wx_friends_logo") { () -> Void in
            
            self.shareGameInfoToWx(1)
        }
        
        var actArray = [Common.LocalizedStringForKey("shareDopTitle"), [dopActWechat, dopActWxFriends]]
        
        var dopActSheet = DOPScrollableActionSheet(actionArray: actArray as [AnyObject])
        dopActSheet.backgroundColor = UIColor(hexString: "e9eeef")
        dopActSheet.cancel.backgroundColor = UIColor(hexString: "e9eeef")
        dopActSheet.cancel.titleLabel?.font = UIFont(name: "system", size: 17)
        
        dopActSheet.cancel.contentVerticalAlignment = UIControlContentVerticalAlignment.Center
        dopActSheet.cancel.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center
        dopActSheet.cancel.setTitle(Common.LocalizedStringForKey("canal_Title"), forState: UIControlState.Normal)
        dopActSheet.cancel.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)

        
        var halvingLine = UILabel()
        halvingLine.frame.size = CGSizeMake(dopActSheet.cancel.frame.width - 16, 1)
        halvingLine.frame.origin = CGPointMake(8, dopActSheet.cancel.frame.origin.y)
        halvingLine.backgroundColor = UIColor(hexString: "cccccc")
        dopActSheet.addSubview(halvingLine)

        
        dopActSheet.show()

    }
    
    /**
    分享游戏
    
    :param: scene <#scene description#>
    */
    func shareGameInfoToWx(scene : Int32) -> Bool {
        
        var isIns = WXApi.isWXAppInstalled()
        
        if true == WXApi.isWXAppInstalled() && true == WXApi.isWXAppSupportApi() {
            
            var message = WXMediaMessage()
            message.title = gameDetailsInfo?.gamename
            message.description = gameDetailsInfo?.gamedetial
            
            var ext = WXWebpageObject()
            ext.webpageUrl = gameDetailsInfo!.shareUrl!
            
            var shareImage = Common.imageWithImageSimple(gameTitleCell?.titleImage.image, newSize: CGSize(width: 100, height: 100))
            
            message.mediaObject = ext
            message.mediaTagName = gameDetailsInfo?.gamename
            message.setThumbImage(shareImage)
            
            var req = SendMessageToWXReq()
            req.bText = false
            req.message = message
            req.scene = scene
            
            WXApi.sendReq(req)
            
            return true
            
        } else {
            
            FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(self.view, withTitle: Common.LocalizedStringForKey("downWx"), delayTime: Common.alertDelayTime)
            return false
            
        }
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int){
        if buttonIndex == 1{
            let wxInsallUrl : String = WXApi.getWXAppInstallUrl()
            
            let appStoreUrl = NSURL(string: wxInsallUrl)
            
            UIApplication.sharedApplication().openURL(appStoreUrl!)
            
        }
    }
    /**
    点击返回
    
    :param: sender <#sender description#>
    */
    @IBAction func onClickBack(sender: UIBarButtonItem) {
        
        self.down.removeObserver()
        self.down.removePageObserver()
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    /**
    加载游戏详情数据
    */
    func loadGameDetailsData() {
        
        if true == Down_Interface().isNotReachable() {
            
            FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(Common.rootViewController.view, withTitle: Common.LocalizedStringForKey("net_err"), delayTime: Common.alertDelayTime)
            
            self.gameInfoTableView.mj_header.endRefreshing()
            
            return
        }
        
        HttpHelper<GameDetailsInfo>.getGameDetailsInfo(gameId, completionHandlerRet: { (result) -> () in
            
            dispatch_async(dispatch_get_main_queue(),{
                
                if "1001" != result?.code {
                
                    self.gameInfoTableView.mj_header.endRefreshing()
                    return
                
                }
            
                self.gameDetailsInfo = result!.data!
            
                // 强制重新赋值
                if self.itemInfo.gameid == nil{
                    // "gamename", "version","downurl","pageName","filesize","icon","gameid"
                    self.itemInfo.gamename = self.gameDetailsInfo?.gamename
                    self.itemInfo.version = self.gameDetailsInfo?.gameid
                    self.itemInfo.downurl = self.gameDetailsInfo?.downurl
                    self.itemInfo.plisturl = self.gameDetailsInfo?.plisturl
                    self.itemInfo.packpagename = self.gameDetailsInfo?.pageName
                    self.itemInfo.filesize = self.gameDetailsInfo?.filesize
                    self.itemInfo.icon = self.gameDetailsInfo?.icon
                    self.itemInfo.gameid = self.gameDetailsInfo?.gameid
                
                    self.down.itemInfo = self.itemInfo
                }
            
                self.gameInfoTableView.mj_header.endRefreshing()
                self.gameInfoTableView.reloadData()
                self.down.enabled = true
                
                if nil != self.gameDetailsInfo?.shareUrl {
                    
                    self.shareBarBtn.enabled = true
                    
                }
            })
        })
    }
    
    /**
    加载游戏评论信息
    */
    func loadGameReviewInfo() {
        
        if true == Down_Interface().isNotReachable() {
            
            FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(Common.rootViewController.view, withTitle: Common.LocalizedStringForKey("net_err"), delayTime: Common.alertDelayTime)
            
            self.gameInfoTableView.mj_footer.endRefreshing()
            
            return
        }
        
        HttpHelper<ReViewInfoRet>.getReViewInfo(gameId, pagenum: pageNum, pagesize: pagesize) { (result) -> () in
            
            dispatch_async(dispatch_get_main_queue(),{
                
                if "1001" != result?.code {
                
                    self.gameInfoTableView.mj_footer?.endRefreshing()
                    return
                }
            
                if nil == result!.data {
                    self.gameInfoTableView.mj_footer?.endRefreshing()
                    return
                }
            
            
                if self.pageNum > 1 {
                
                    self.reviewArray = self.reviewArray + result!.data!
                    self.pageNum++
                
                } else {
                
                    self.reviewArray = result!.data!
                    self.pageNum++
                }
            
                self.gameInfoTableView.mj_footer?.endRefreshing()
                
                if result!.data?.count <  self.pagesize {
                
                    self.gameInfoTableView.mj_footer = nil
                }
                
                self.gameInfoTableView.reloadData()
            })
            
        }
    }

    /**
    点击下载按钮
    */
    @IBAction func onClickDown(sender : AnyObject){
        
        down.clickDownBtn();
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: - table view 代理
extension AppInfoViewController : UITableViewDelegate, UITableViewDataSource {
    
    /**
    返回行数
    
    :param: tableView
    :param: section
    
    :returns:
    */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if nil == gameDetailsInfo {
            
            return 0
            
        }
        
        if gameDetailsInfo?.situation != "" {
            return 6 + reviewArray.count
        }
        
        return 5 + reviewArray.count
        
    }

    
    /**
    创建cell
    
    :param: tableView
    :param: indexPath
    
    :returns:
    */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell : AnyObject
        
        switch indexPath.row {
            
            //游戏title
        case 0 :
            cell = tableView.dequeueReusableCellWithIdentifier("GameTitleTableViewCell", forIndexPath: indexPath) as! GameTitleTableViewCell
            
            gameTitleCell = cell as? GameTitleTableViewCell
            gameTitleCell!.titleGameName.text = gameDetailsInfo!.gamename
            gameTitleCell!.titleGameSize.text = gameDetailsInfo!.filesize! + "M"
            gameTitleCell?.setGameInfo(gameDetailsInfo!.gamedesc!)
            gameTitleCell!.titleImage.sd_setImageWithURL(NSURL(string: gameDetailsInfo!.icon!))
            gameTitleCell!.titleImage.layer.masksToBounds = true
            gameTitleCell!.titleImage.layer.cornerRadius = Common.iconCornerRadius
            gameTitleCell!.titleImage.layer.borderWidth = 1
            gameTitleCell!.titleImage.layer.borderColor = UIColor.whiteColor().CGColor
            
        case 1 :
            cell = tableView.dequeueReusableCellWithIdentifier("GameImageTableViewCell", forIndexPath: indexPath) as! GameImageTableViewCell
            
            var gameImageCell = cell as! GameImageTableViewCell
            
            if 0 != gameDetailsInfo!.verimage.count {
                
                gameImageCell.addScrollImageView(gameDetailsInfo!.verimage)
                break
            }
            
            if 0 != gameDetailsInfo!.viewimage.count {
                
                gameImageCell.gameImage.sd_setImageWithURL(NSURL(string: gameDetailsInfo!.viewimage[0].bigimage!))
                
                break
                
            }
            
        case 2 :
            cell = tableView.dequeueReusableCellWithIdentifier("GameRecommendTableViewCell", forIndexPath: indexPath) as! GameRecommendTableViewCell
            
            gameRecommendCell = cell as? GameRecommendTableViewCell
            
            gameRecommendCell!.setGameRecommendText(gameDetailsInfo!.gamedetial!)
            
        case 3 :
            
            if gameDetailsInfo!.situation == "" {
                cell = createGameAppInfoTableViewCell(tableView, cellForRowAtIndexPath: indexPath)
            } else {
                cell = createGameUpdateInfoTableViewCell(tableView, cellForRowAtIndexPath: indexPath)
            }
            
        case 4 :
            
            if gameDetailsInfo!.situation == "" {
                cell = createGameReviewTableViewCell(tableView, cellForRowAtIndexPath: indexPath)
            } else {
                cell = createGameAppInfoTableViewCell(tableView, cellForRowAtIndexPath: indexPath)
            }
            
        case 5 :
            if gameDetailsInfo!.situation == "" {
                cell = createGameReviewInfoTableViewCell(tableView, cellForRowAtIndexPath: indexPath);
            } else {
                cell = createGameReviewTableViewCell(tableView, cellForRowAtIndexPath: indexPath);
            }
            
        
        default :
            
            cell = createGameReviewInfoTableViewCell(tableView, cellForRowAtIndexPath: indexPath)
        }
        
        var newcell = cell as! UITableViewCell
        
        newcell.selectionStyle = UITableViewCellSelectionStyle.None
        
        return newcell
    }
    
    func createGameReviewInfoTableViewCell(tableview: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell : UITableViewCell = tableview.dequeueReusableCellWithIdentifier("GameReviewInfoTableViewCell", forIndexPath: indexPath) as! UITableViewCell
            
        var reviewCell = cell as! GameReviewInfoTableViewCell
        
        var cellNum = 5
        
        if gameDetailsInfo?.situation != "" {
           cellNum++
        }
            
        reviewCell.setContentText(reviewArray[indexPath.row - cellNum].com_content!)
        reviewCell.userNameLabel.text = reviewArray[indexPath.row - cellNum].nickname
        reviewCell.datetimeLabel.text = reviewArray[indexPath.row - cellNum].com_datetime
        reviewCell.avatarImage.sd_setImageWithURL(NSURL(string: reviewArray[indexPath.row - cellNum].avatar!))
            
        reviewCell.avatarImage.layer.masksToBounds = true
        reviewCell.avatarImage.layer.cornerRadius = reviewCell.avatarImage.bounds.size.width * 0.5
            
        return cell
    }
    
    /**
    创建游戏评论Cell
    
    - parameter tableview:
    - parameter indexPath:
    
    - returns:
    */
    func createGameReviewTableViewCell(tableview: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell : UITableViewCell = tableview.dequeueReusableCellWithIdentifier("GameReviewTableViewCell") as! UITableViewCell
        var gameReviewCell = cell as! GameReviewTableViewCell
            
        gameReviewCell.delegate = self
        
        return gameReviewCell
    }
    
    /**
    创建游戏信息cell
    
    - parameter tableView:
    - parameter indexPath:
    
    - returns:
    */
    func createGameAppInfoTableViewCell(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var gameAppInfoCell = tableView.dequeueReusableCellWithIdentifier("GameAppInfoTableViewCell") as! GameAppInfoTableViewCell
        
        gameAppInfoCell.gametypeLable.text = gameDetailsInfo?.gametype
        gameAppInfoCell.developersLable.text = gameDetailsInfo?.developers
        gameAppInfoCell.updateTimeLable.text = gameDetailsInfo?.updateTime
        gameAppInfoCell.versionLable.text = gameDetailsInfo?.viewVersion
        
        return gameAppInfoCell as UITableViewCell
    }
    
    /**
    创建更新信息
    
    - parameter tableView:
    - parameter indexPath:
    
    - returns:
    */
    func createGameUpdateInfoTableViewCell(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var updateInfoCell = tableView.dequeueReusableCellWithIdentifier("UpdateInfoTableViewCell") as! UpdateInfoTableViewCell
        updateInfoCell.setUpdateInfo(self.gameDetailsInfo!.updateTime!, situation: self.gameDetailsInfo!.situation!)
        
        return updateInfoCell as UITableViewCell
    }
    
    /**
    修改cell高度
    
    :param: tableView
    :param: indexPath
    
    :returns:
    */
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        switch indexPath.row {
            
        case 0 :
            
            if .UIDeviceResolution_iPhoneRetina4 == resolution() {
                
                return 85
                
            }
            
            return 111
            
            
        case 1 :
            
            if 0 != gameDetailsInfo!.verimage.count {
                return 210 + 66
            }
            
            return ((self.view.frame.width - 24) / (7 / 3)) + 66
            
        case 2 :
            
            if nil == gameDetailsInfo {
                return 0
            }
            
            return getRecommendCellHight(gameDetailsInfo!.gamedetial!)

            
        case 3 :
            
            if gameDetailsInfo?.situation == "" {
                return 174
            } else {
                return tableView.fd_heightForCellWithIdentifier("UpdateInfoTableViewCell", configuration: { (cell) -> Void in
                    
                    var updateInfoTableViewCell: UpdateInfoTableViewCell = cell as! UpdateInfoTableViewCell
                    updateInfoTableViewCell.fd_enforceFrameLayout = true
                    updateInfoTableViewCell.setUpdateInfo(self.gameDetailsInfo!.updateTime!, situation: self.gameDetailsInfo!.situation!)
                    
                });
            }
            
        case 4 :
            if gameDetailsInfo?.situation == "" {
                return 106
            } else {
                return 174
            }
            
        case 5:
            if gameDetailsInfo?.situation == "" {
                return getContentCellHight(reviewArray[indexPath.row - 5].com_content!)
            } else {
                return 106
            }
            
        default :

            return getContentCellHight(reviewArray[indexPath.row - 6].com_content!)
            
        }
        
    }
}

// MARK: - 评论扩展
extension AppInfoViewController : GameReviewDelegate, KeyboardTextFieldDelegate, UITextFieldDelegate {
    
    /**
    点击立即评论
    */
    func addReview() {
        
        self.view.addSubview(dimBackground)
        var gr = UITapGestureRecognizer(target: self, action: "hideText:")
        dimBackground.addGestureRecognizer(gr)
        
        kbText?.showView()
    }
    
    /**
    点击发送
    */
    func onClickSendMessage() {
        
        if (3 > count(kbText!.textField!.text)) {
            
            FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(self.kbText!, withTitle: Common.LocalizedStringForKey("alert_review_msg"), delayTime: 2)
            
            return
        }
        
        HttpHelper<CommmonMsgRet>.sendComment(gameId, content: kbText!.textField!.text) { (result) -> () in
            
            if ("1001" != result?.code!) {
                return
            }
            
            dispatch_async(dispatch_get_main_queue(),{
                
                self.loadGameReviewInfo()
                self.gameInfoTableView.reloadData()
                self.dimBackground.removeFromSuperview()
                
            })
        }
        
        self.kbText!.textField!.text = ""
    }
    
    /**
    键盘回车
    
    :param: textField
    
    :returns:
    */
    func growingTextViewShouldReturn(growingTextView: HPGrowingTextView) -> Bool {
        
        onClickSendMessage()
        
        return true
    }
    
    
    /**
    限制输入字符数
    
    :param: textField <#textField description#>
    :param: range     <#range description#>
    :param: string    <#string description#>
    
    :returns: <#return value description#>
    */
    func growingTextView(growingTextView : HPGrowingTextView, shouldChangeTextInRange range: NSRange, replacementText text: NSString) -> Bool {
        
        if kbText!.textField == growingTextView {
            
            var toString = growingTextView.text + (text as String)
            
            
            if 200 < count(toString) && "" != toString  {
                
                return false
                
            }
        }
        
        return true
        
    }
    
    func growingTextView(growingTextView : HPGrowingTextView, willChangeHeight height : Float) {
        
        var diff = growingTextView.frame.height - CGFloat(height)
        
        var r = kbText!.frame;
        r.size.height -= diff;
        r.origin.y += diff;
        kbText!.frame = r;
        
    }
    
    func hideText(tap : UITapGestureRecognizer) {
        
        kbText?.hidden = true
        dimBackground.removeFromSuperview()
    }
}

