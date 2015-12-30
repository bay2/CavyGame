//
//  ClassAllItemTbVC.swift
//  CavyGame
//  每一个类别的游戏列表
//  Created by longjining on 15/8/20.
//  Copyright (c) 2015年 com.lvwenhan. All rights reserved.
//

import UIKit

class ClassAllItemTbVC: GameListBaseTableViewController {

    var gameClassID : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        MJRefreshAdapter.setupRefreshHeader(self.tableView, target: self, action: "headerRefresh")
        MJRefreshAdapter.setupRefreshFoot(self.tableView, target: self, action: "footerRefresh")
        loadData()
        
        
        self.view.backgroundColor = Common.tableBackColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func loadData(){
        // 加载第一页
        
        if true == Down_Interface().isNotReachable() {
            
            FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(self.view, withTitle: Common.LocalizedStringForKey("net_err"), delayTime: Common.alertDelayTime)
            self.tableView.mj_header?.endRefreshing()
            return
        }
        
        
        var nowPageSize = self.currPage * self.pageSize
        
        HttpHelper<GameListInfo>.getClassAllItemList(gameClassID, pagenum: 1, pagesize: nowPageSize) { (result) -> () in
            
            if result == nil{
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.mj_header?.endRefreshing()
                })
            }else{
                
                var nowPageSize = self.currPage * self.pageSize
                
                let gamesInfo : GameListInfo = result!
                
                if self.gameListInfo.gameList.count == 0 {
                    self.gameListInfo = gamesInfo
                }else{
                    if gamesInfo.gameList.count > 0 {
                        self.gameListInfo.gameList.removeAll(keepCapacity: false)
                        self.gameListInfo.gameList = gamesInfo.gameList
                    }
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.mj_header?.endRefreshing()
                    self.tableView.reloadData()
                })
                self.updateVersion()
                NSNotificationCenter.defaultCenter().postNotificationName(Common.notifyLoadFinishData, object:nil)
            }
        }
    }
    
    override func loadMoreData(){
        
        if true == Down_Interface().isNotReachable() {
            
            FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(self.view, withTitle: Common.LocalizedStringForKey("net_err"), delayTime: Common.alertDelayTime)
            
            return
        }
        
        self.currPage++
        HttpHelper<GameListInfo>.getClassAllItemList(gameClassID, pagenum: currPage, pagesize: pageSize) { (result) -> () in
            
            if result == nil{
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.mj_footer?.endRefreshing()
                })
            }else{
                let gamesInfo : GameListInfo = result!
                
                if gamesInfo.pageNum == nil || gamesInfo.pageNum < self.currPage {
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.tableView.mj_footer?.endRefreshing()
                        self.removeFooterRefresh()
                    })
                    return
                }
                
                
                if self.gameListInfo.gameList.count == 0 {
                    self.gameListInfo = gamesInfo
                }else{
                    if gamesInfo.gameList.count > 0 {
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
        }
    }
    
    override func headerRefresh(){
        
        self.loadData()
        super.headerRefresh()
    }
    
    override func footerRefresh(){
        
        
        self.loadMoreData()
        super.footerRefresh()
    }
    
    // MARK: - Table view data source
}
