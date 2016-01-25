//
//  RankListVC.swift
//  
//
//  Created by Jessica on 16/1/20.
//
//

import UIKit

class RankListVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let screenRect = UIScreen.mainScreen().bounds
    
    var rankListView     = UIView()
    var tableView        = UITableView()
    var perListWidth     = CGFloat()
    var rankListBtnArray = NSMutableArray()

    var listCount :Int   = 0        // 排行榜个数：可直接改个数
    var listCurrentIndex = 0        // 默认显示第一个排行榜
    var currPage         = 1        // 下拉加载当前页
    let pageSize         = 10       // 每页获取的数目
    
    var btn_blogPage : String = ""
    var gameListInfo : GameListInfo = GameListInfo()
    var rankListArray = Array<RankList>()
    
    // MARK: View
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btn_blogPage = Common.notifyAdd_Page2
        
        self.loadListName()
        self.addTableView()
        self.currentListColor()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "nofityShowLeftView:", name: Common.notifyShowLeftView, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "nofityShowHomeView:", name: Common.notifyShowHomeView, object: nil)
        
        MJRefreshAdapter.setupRefreshFoot(self.tableView, target: self, action: "footerRefresh")
        MJRefreshAdapter.setupRefreshHeader(self.tableView, target: self, action: "headerRefresh")
    }
    
    /**
      加载排行榜列表名称信息
    */
    func loadListName(){
        // web接口(get):http://game.tunshu.com/mobileIndex/index?ac=newranking
        
        HttpHelper<RankListInfo>.getRankingListName { (result) -> () in
 
            if result == nil {
                return
            }
            
            let rankResult : RankListInfo = result!
            
            for temp in rankResult.data! {
                self.rankListArray.append(temp)
            }

            self.listCount = self.rankListArray.count

            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.addRankListView()
                self.loadData()
            })
        }
    }
    
    /**
    添加TableView
    */
    func addTableView(){
        
        var cutHight: CGFloat = 64 + 30
        
        if .UIDeviceResolution_iPhoneRetina4 == resolution() {
            
            cutHight += 41.5
            
        } else {
            
            cutHight += 49 // tab的总体高度 48 ＋ 1
        }
        
        self.tableView = UITableView(frame: CGRectMake(0, 30, screenRect.width, screenRect.height - cutHight), style: UITableViewStyle.Plain)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        if (8.0 <= Common.getDeviceIosVersion()) {
            
            //使分割线靠最左边
            self.tableView.layoutMargins = UIEdgeInsetsZero
        }
        
        self.tableView.backgroundColor = Common.tableBackColor
        
        var leftBtn = UIBarButtonItem(image: UIImage(named: "icon_back"), style: UIBarButtonItemStyle.Bordered, target: self, action: Selector("onClickBack"))
        leftBtn.imageInsets = UIEdgeInsetsMake(0, -5, 0, -5)
        
        self.navigationItem.leftBarButtonItem = leftBtn
        
        self.tableView.separatorInset = UIEdgeInsetsZero
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        switch resolution() {
            
        case .UIDeviceResolution_iPhoneRetina4 :
            self.tableView.registerNib(UINib(nibName: "GameInfoTableViewCell_iPhone4", bundle:nil), forCellReuseIdentifier: "GameInfoTableViewCellid")
        default:
            self.tableView.registerNib(UINib(nibName: "GameInfoTableViewCell", bundle:nil), forCellReuseIdentifier: "GameInfoTableViewCellid")
        }
        
        self.view.addSubview(self.tableView)
    }
    
    /**
    添加排行榜视图
    */
    func addRankListView(){
        
        self.rankListView = UIView(frame: CGRectMake(0, 0, screenRect.width, 30))
        rankListView.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 30)
        rankListView.backgroundColor = UIColor.clearColor()
        
        self.perListWidth = UIScreen.mainScreen().bounds.width / CGFloat(self.listCount)
        
        print("listCount in 【addRankListView】\(self.listCount)\n")
        
        for var i = 0 ; i < self.listCount ; i++ {
            
            var perListButton = UIButton()
            
            perListButton.titleLabel?.textAlignment = NSTextAlignment.Center
            perListButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
            perListButton.frame = CGRectMake(perListWidth * CGFloat(i), 0, perListWidth, 30)
            perListButton.titleLabel?.font = UIFont.systemFontOfSize(14)
            
            if i == 0 {
                perListButton.setTitleColor(UIColor(hexString: "#3e76db"), forState: UIControlState.Normal)
            }else{
                perListButton.setTitleColor(UIColor(hexString: "#868686"), forState: UIControlState.Normal)
            }
            perListButton.setTitle(self.rankListArray[i].rankname, forState: UIControlState.Normal)
            perListButton.tag = 1000 + i
            perListButton.addTarget(self, action: "orderAction:", forControlEvents: UIControlEvents.TouchUpInside)
            
            rankListBtnArray.insertObject(perListButton, atIndex: i)
            
            rankListView.addSubview(perListButton)
        }
        
        self.view.addSubview(self.rankListView)
    }
    
    /**
    返回
    */
    func onClickBack() {
        
        self.navigationController?.popViewControllerAnimated(true)
        
    }
    
    // MARK: 切换排行榜的事件
    func orderAction(sender:UIButton) {
        
        self.listCurrentIndex = sender.tag - 1000
               
        print("排行\(self.rankListArray[self.listCurrentIndex].rankname!)\n")
        self.loadData()

        self.currentListColor()
        self.tableView.reloadData()
    }
    
    // 选中当前排行榜的字是蓝色
    func currentListColor(){
        
        for var i = 0 ; i < listCount ; i++ {
            
            if self.listCurrentIndex == i {
                rankListBtnArray[i].setTitleColor(UIColor(hexString: "#3e76db"), forState: UIControlState.Normal)
            }else{
                // let defaultColor = Common.  // #868686
                rankListBtnArray[i].setTitleColor(UIColor(hexString: "#868686"), forState: UIControlState.Normal)
            }
        }
    }
    
    // 加载
    func loadData(){

        let rankListType: String = self.rankListArray[self.listCurrentIndex].ranktype!
        
        // 加载第一页
        HttpHelper<GameListInfo>.getRankingList(1, ranktype: rankListType, pagesize: pageSize * currPage, completionHandlerRet:{(result) -> () in
            
            if result == nil{
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.mj_header?.endRefreshing()
                })
            }else{
                
                let gamesInfo : GameListInfo = result!
                
                if self.gameListInfo.gameList.count == 0 {
                    self.gameListInfo = gamesInfo
                }else{
                    if gamesInfo.gameList.count > 0{
                        self.gameListInfo.gameList.removeAll(keepCapacity: false)
                        self.gameListInfo.gameList = gamesInfo.gameList
                    }
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                    self.tableView.mj_header?.endRefreshing()
                })
                self.updateVersion()
                NSNotificationCenter.defaultCenter().postNotificationName(Common.notifyLoadFinishData, object:nil)
            }
        })

        if true == Down_Interface().isNotReachable() {
            
            FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(self.view, withTitle: Common.LocalizedStringForKey("net_err"), delayTime: Common.alertDelayTime)
            return
        }
        
    }
    
    // 移除
    func removeFooterRefresh(){
        
        self.tableView.mj_footer = nil
        
    }
    
    func updateVersion(){
        
        for item in self.gameListInfo.gameList{
            if (item.gameSubInfo != nil){
                DownloadManager.getInstance().needUpdate(item.gameSubInfo.gameid, version: item.gameSubInfo.version, downUrl : item.gameSubInfo.downurl)
            }
        }
    }
    
    // 通知
    func nofityShowHomeView(notification:NSNotification){
        
        self.tableView.allowsSelection = true
        self.tableView.scrollEnabled = true
    }
    // 通知
    func nofityShowLeftView(notification:NSNotification){
        
        self.tableView.allowsSelection = false
        self.tableView.scrollEnabled = false
    }
    
    // 下拉刷新
    func headerRefresh(){
        // loadData()
        self.loadData()
        
    }
    
    // 上拉加载
    func footerRefresh(){
        //loadMoreData()
        if true == Down_Interface().isNotReachable() {
            
            FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(self.view, withTitle: Common.LocalizedStringForKey("net_err"), delayTime: Common.alertDelayTime)
            self.tableView.mj_footer?.endRefreshing()
            return
        }
        
        self.currPage++
        HttpHelper<GameListInfo>.getRankList (currPage, pagesize : pageSize, completionHandlerRet:{(result) -> () in
            
            if result == nil{
                
            }else{
                let gamesInfo : GameListInfo = result!
                if self.gameListInfo.gameList.count == 0 {
                    self.gameListInfo = gamesInfo
                }else{
                    
                    if gamesInfo.pageNum == nil || gamesInfo.pageNum < self.currPage {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.tableView.mj_footer?.endRefreshing()
                            self.removeFooterRefresh()
                        })
                        return
                    }
                    
                    if gamesInfo.gameList.count > 0{
                        self.gameListInfo.gameList = self.gameListInfo.gameList + gamesInfo.gameList
                    }else{
                        self.removeFooterRefresh()
                        return
                    }
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.mj_footer?.endRefreshing()
                    self.tableView.reloadData()
                })
            }
        })


    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: TableViewDelegate ,TableViewDatasource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.gameListInfo.gameList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("GameInfoTableViewCellid", forIndexPath: indexPath) as! GameInfoTableViewCell
        
        //使分割线靠最左边
        if (8.0 <= Common.getDeviceIosVersion()) {
            
            cell.layoutMargins = UIEdgeInsetsZero
        }
        
        var gameInfoItem = self.gameListInfo.gameList[indexPath.row].gameSubInfo
        
        if gameInfoItem == nil{
            return cell;
        }
        cell.title.text = gameInfoItem.gamename
        cell.detail.text = gameInfoItem.gamedesc
        cell.down.whichPage = btn_blogPage
        cell.itemInfo = gameInfoItem
        
        cell.icon.sd_setImageWithURL(NSURL(string: gameInfoItem.icon!), placeholderImage: UIImage(named: "icon_game"))
        // 设置圆角
        cell.icon.layer.masksToBounds = true;
        cell.icon.layer.cornerRadius = Common.iconCornerRadius
        
        var downCnt = gameInfoItem.downcount
        downCnt = downCnt! + Common.LocalizedStringForKey("downtime")
        var fileSize = gameInfoItem.filesize
        var downInfo = fileSize! + "M"
        cell.sizeAndDownCnt.text = downInfo
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if .UIDeviceResolution_iPhoneRetina4 == resolution() {
            
            return 93.5
        }
        
        return 129.0
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        //使用选择的行恢复默认状态
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        showGameDetail(gameListInfo.gameList[indexPath.row].gameSubInfo.gameid!,
            gameSubInfo : gameListInfo.gameList[indexPath.row].gameSubInfo)
    }
    
    func showGameDetail(gameID : String!, gameSubInfo : GameSubInfo){
        
        
        var appInfoVc = Common.getViewControllerWithIdentifier("AppInfo", identifier: "AppInfoView") as! AppInfoViewController
        
        appInfoVc.gameId = gameID
        appInfoVc.itemInfo = gameSubInfo
        
        
        Common.rootViewController.homeViewController.navigationController?.pushViewController(appInfoVc, animated: true)
    }

    
}

