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

    
    func headerRefresh(){
        
    }
    
    func footerRefresh(){
        
    }
    
    func removeFooterRefresh(){
        
        self.tableView.mj_footer = nil
        
    }
    
}
