//
//  RankingVC.swift
//  
//
//  Created by Jessica on 16/1/25.
//
//

import UIKit

class RankingVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let screenRect     = UIScreen.mainScreen().bounds

    var rankListView   = UIView()
    var rankListArray  = Array<RankList>()
    var perListWidth   = CGFloat()
    var listCount :Int = 0// 排行榜个数：可直接改个数

    var scrollView     = UIScrollView()
    var currentIndex   = 0// 默认显示第一个排行榜
    
    // MARK: View
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadListName()
  
    }
    
    /**
    添加排行榜滚动视图上的 TableView
    */
    func addScrollerViewWithTableView(){
        
        var cutHight: CGFloat = 64 + 30
        
        if .UIDeviceResolution_iPhoneRetina4 == resolution() {
            
            cutHight += 41.5
            
        } else {
            
            cutHight += 49 // tab的总体高度 48 ＋ 1
        }
        self.scrollView = UIScrollView(frame:CGRectMake(0, 30, screenRect.width, screenRect.height - cutHight))
        self.scrollView.contentSize = CGSizeMake(screenRect.width * CGFloat(self.listCount), screenRect.height - cutHight)
        self.scrollView.scrollEnabled = false   // 关闭滑动翻页
        for var i = 0 ; i < self.listCount ; i++ {
            
            // tableView 属性
            let rankTableView = RankTableView(frame: CGRectMake(screenRect.width * CGFloat(i), 0, screenRect.width, screenRect.height - cutHight))

            rankTableView.tag = 2000 + i
            rankTableView.rankType = self.rankListArray[i].ranktype!
            rankTableView.loadData()
            
            
            MJRefreshAdapter.setupRefreshFoot(rankTableView, target: self, action: "footerRefresh")
            MJRefreshAdapter.setupRefreshHeader(rankTableView, target: self, action: "headerRefresh")
            
            if (8.0 <= Common.getDeviceIosVersion()) {
                
                //使分割线靠最左边
                rankTableView.layoutMargins = UIEdgeInsetsZero
            }
            
            rankTableView.backgroundColor = Common.tableBackColor
            
            var leftBtn = UIBarButtonItem(image: UIImage(named: "icon_back"), style: UIBarButtonItemStyle.Bordered, target: self, action: Selector("onClickBack"))
            leftBtn.imageInsets = UIEdgeInsetsMake(0, -5, 0, -5)
            
            self.navigationItem.leftBarButtonItem = leftBtn
            
            rankTableView.separatorInset = UIEdgeInsetsZero
            
            rankTableView.separatorStyle = UITableViewCellSeparatorStyle.None
            
            switch resolution(){
                
            case .UIDeviceResolution_iPhoneRetina4 :
                rankTableView.registerNib(UINib(nibName: "GameInfoTableViewCell_iPhone4", bundle:nil), forCellReuseIdentifier: "GameInfoTableViewCellid")
            default:
                rankTableView.registerNib(UINib(nibName: "GameInfoTableViewCell", bundle:nil), forCellReuseIdentifier: "GameInfoTableViewCellid")
            }
        
            self.scrollView.addSubview(rankTableView)
            
            rankTableView.dataSource = self
            rankTableView.delegate = self
        }
        
        self.view.addSubview(self.scrollView)
    }
    
    /**
    添加排行榜视图
    */
    func addRankListView(){
        
        self.rankListView = UIView(frame: CGRectMake(0, 0, screenRect.width, 30))
        rankListView.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 30)
        rankListView.backgroundColor = UIColor.clearColor()
        
        self.perListWidth = UIScreen.mainScreen().bounds.width / CGFloat(self.listCount)
        
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
            
            rankListView.addSubview(perListButton)
        }
        
        self.view.addSubview(self.rankListView)
    }

    /**
    加载排行榜列表信息
    */
    func loadListName(){

        HttpHelper<RankListInfo>.getRankingListName { (result) -> () in
            
            if result == nil {
                return
            }
            
            let rankResult : RankListInfo = result!
            
            self.rankListArray = rankResult.data!
            
            self.listCount = self.rankListArray.count
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.addRankListView()
                self.addScrollerViewWithTableView()
            })
        }
    }
    
    // MARK: 切换排行榜的事件
    func orderAction(sender:UIButton) {

        // 改变原来的颜色变成默认灰色
        var btn = rankListView.viewWithTag(1000 + currentIndex) as! UIButton
        btn.setTitleColor(UIColor(hexString: "#868686"), forState: UIControlState.Normal)
        
        // 更改更改当前选中的值
        self.currentIndex = sender.tag - 1000
        self.currentListColor()
        
        self.scrollView.setContentOffset(CGPointMake(screenRect.width * CGFloat(self.currentIndex), 0), animated: true)
        print("排行\(currentIndex)\n")

        let catchTableView = self.scrollView.viewWithTag(2000 + currentIndex) as! RankTableView
        
        catchTableView.loadData()
    }
    
    // 选中当前排行榜的字是蓝色
    func currentListColor(){
        
        var btn = rankListView.viewWithTag(1000 + currentIndex) as! UIButton
        
        btn.setTitleColor(UIColor(hexString: "#3e76db"), forState: UIControlState.Normal)
        
    }
    
    func footerRefresh(){
        let rankTableView = scrollView.viewWithTag(2000 + currentIndex) as! RankTableView
        rankTableView.footerRefresh()
    }
    
    func headerRefresh(){
        let rankTableView = scrollView.viewWithTag(2000 + currentIndex) as! RankTableView
        rankTableView.loadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: TableViewDelegate ,TableViewDatasource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if rankListArray.isEmpty {
            return 0
        }
        let rankTableView = scrollView.viewWithTag(2000 + currentIndex) as! RankTableView
        
        return rankTableView.gameListInfo.gameList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
        let rankTableView = scrollView.viewWithTag(2000 + currentIndex) as! RankTableView
        
        var cell = rankTableView.dequeueReusableCellWithIdentifier("GameInfoTableViewCellid", forIndexPath: indexPath) as! GameInfoTableViewCell
        
        //使分割线靠最左边
        if (8.0 <= Common.getDeviceIosVersion()) {
            
            cell.layoutMargins = UIEdgeInsetsZero
        }
        
        var gameInfoItem = rankTableView.gameListInfo.gameList[indexPath.row].gameSubInfo
        
        if gameInfoItem == nil{
            return cell;
        }
        cell.title.text = gameInfoItem.gamename
        cell.detail.text = gameInfoItem.gamedesc
        cell.down.whichPage = rankTableView.btn_blogPage
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
        
        let rankTableView = scrollView.viewWithTag(2000 + currentIndex) as! RankTableView
        
        //使用选择的行恢复默认状态
        rankTableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        let gameArray = rankTableView.gameListInfo.gameList
        showGameDetail(gameArray[indexPath.row].gameSubInfo.gameid!,
            gameSubInfo : gameArray[indexPath.row].gameSubInfo)
    }
    
    // 游戏详情
    func showGameDetail(gameID : String!, gameSubInfo : GameSubInfo){
        
        var appInfoVc = Common.getViewControllerWithIdentifier("AppInfo", identifier: "AppInfoView") as! AppInfoViewController
        
        appInfoVc.gameId = gameID
        appInfoVc.itemInfo = gameSubInfo
        
        Common.rootViewController.homeViewController.navigationController?.pushViewController(appInfoVc, animated: true)
    }


}
