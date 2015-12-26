//
//  RefreshTableViewController.swift
//  CavyGame
//  添加上拉，下拉刷新的UITableViewController
//  如果需要下拉刷新调用 setupRefreshHeader 重写headerRefresh
//  如果需要上拉刷新调用 setupRefreshFoot   重写footerRefresh
//  Created by longjining on 15/9/1.
//  Copyright (c) 2015年 com.lvwenhan. All rights reserved.
//

import UIKit

class RefreshTableViewController: UITableViewController {

    var refreshHeader : SDRefreshHeaderView!
    var refreshFoot : SDRefreshFooterView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupRefreshHeader(){
        refreshHeader = SDRefreshHeaderView();
        
        // 默认是在navigationController环境下，如果不是在此环境下，请设置 refreshHeader.isEffectedByNavigationController = NO;
        refreshHeader.isEffectedByNavigationController = false
        refreshHeader.addToScrollView(self.tableView)
        
        refreshHeader.addTarget(self, refreshAction:"headerRefresh")
    }
    
    func headerRefresh(){
        
        self.delay(2.0, closure: { () -> () in
            
            self.refreshHeader.endRefreshing()
        })
    }
    
    func setupRefreshFoot(){
        refreshFoot = SDRefreshFooterView();
        
        // 默认是在navigationController环境下，如果不是在此环境下，请设置 refreshHeader.isEffectedByNavigationController = NO;
        refreshFoot.isEffectedByNavigationController = false
        refreshFoot.addToScrollView(self.tableView)
        
        refreshFoot.addTarget(self, refreshAction:"footerRefresh")
    }
    
    func footerRefresh(){
        
        self.delay(2.0, closure: { () -> () in
            if self.refreshFoot == nil{
                return
            }
            self.refreshFoot.endRefreshing()
        })
    }
    
    func removeFooterRefresh(){
        
        if self.refreshFoot != nil {
            
            self.refreshFoot.scrollView.contentInset = UIEdgeInsetsZero;
            self.refreshFoot.removeFromSuperview()
            
            self.refreshFoot = nil
        }
        
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
}
