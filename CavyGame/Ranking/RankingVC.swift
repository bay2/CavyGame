//
//  RankingVC.swift
//  CavyGame
//  排行功能
//  Created by longjining on 15/8/10.
//  Copyright (c) 2015年 com.lvwenhan. All rights reserved.
//

import UIKit

class RankingVC : GameListBaseTableViewController {
    

    override func viewDidLoad() {
        super.viewDidLoad()

        btn_blogPage = Common.notifyAdd_Page2

        loadData()
        
        setSpaceHeadView()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "nofityShowLeftView:", name: Common.notifyShowLeftView, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "nofityShowHomeView:", name: Common.notifyShowHomeView, object: nil)
        
        MJRefreshAdapter.setupRefreshFoot(self.tableView, target: self, action: "footerRefresh")
        MJRefreshAdapter.setupRefreshHeader(self.tableView, target: self, action: "headerRefresh")

    }
    
    override func loadData(){
        // 加载第一页
        
        if true == Down_Interface().isNotReachable() {
            
            FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(self.view, withTitle: Common.LocalizedStringForKey("net_err"), delayTime: Common.alertDelayTime)
            return
        }
        
        super.loadData()
    }
    
    func nofityShowHomeView(notification:NSNotification){
        
        self.tableView.allowsSelection = true
        self.tableView.scrollEnabled = true
    }
    
    func nofityShowLeftView(notification:NSNotification){
        
        self.tableView.allowsSelection = false
        self.tableView.scrollEnabled = false
    }
    
    override func headerRefresh(){
        
        self.loadData()
        
        super.headerRefresh()
    }
    
    override func footerRefresh(){
        
        self.loadMoreData()
        super.footerRefresh()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{

        
        var cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)  as! GameInfoTableViewCell

        cell.title.text = "\(indexPath.row + 1). " + cell.title.text!
        
        return cell
    }
}