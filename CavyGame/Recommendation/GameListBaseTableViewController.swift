//
//  GameListBaseTableViewController.swift
//  CavyGame
//
//  Created by longjining on 15/8/12.
//  Copyright (c) 2015年 com.lvwenhan. All rights reserved.
//

import UIKit

class GameListBaseTableViewController: RefreshTableViewController {

    var currPage = 1
    let pageSize = 10   // 每页获取的数目

    var btn_blogPage : String = ""
    var gameListInfo : GameListInfo = GameListInfo()

    override func viewDidLoad() {
        super.viewDidLoad()

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
    }
    
    func onClickBack() {
        
        self.navigationController?.popViewControllerAnimated(true)
        
    }
    
    func loadData(){
        // 加载第一页
        
        HttpHelper<GameListInfo>.getRankList (1, pagesize : pageSize * currPage, completionHandlerRet:{(result) -> () in
            
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
    }
    
    func loadMoreData(){
        
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
    
    func setSpaceHeadView(){
        var headerView = UIView(frame: CGRectMake(0.0, 0.0,
            Common.screenWidth,
            Common.controlTopSpace))
        headerView.backgroundColor = Common.tableBackColor
        self.tableView.tableHeaderView = headerView
    }
    
    func updateVersion(){
        
        for item in self.gameListInfo.gameList{
            if (item.gameSubInfo != nil){
                DownloadManager.getInstance().needUpdate(item.gameSubInfo.gameid, version: item.gameSubInfo.version, downUrl : item.gameSubInfo.downurl)
            }
        }
    }
}

extension GameListBaseTableViewController : UITableViewDataSource, UITableViewDelegate{
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self.gameListInfo.gameList.count
    }
    
    override
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
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

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        
        if .UIDeviceResolution_iPhoneRetina4 == resolution() {
            
            return 93.5
            
        }
        
        return 129.0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
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