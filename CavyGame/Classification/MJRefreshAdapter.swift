//
//  MJRefreshAdapter.swift
//  
//
//  Created by xuemincai on 15/12/27.
//
//

import UIKit

class MJRefreshAdapter: NSObject {
    
    
    /**
    安装下拉刷新
    
    - parameter tableView:
    - parameter target:
    - parameter action:    
    */
    static func setupRefreshHeader(tableView: UITableView, target: AnyObject, action: Selector){
        
        var header = MJRefreshNormalHeader(refreshingTarget: target, refreshingAction: action)
        header.lastUpdatedTimeLabel.hidden = true
        header.setTitle(Common.LocalizedStringForKey("SDRefreshViewRefreshingStateText"), forState: MJRefreshState.Refreshing)
        header.setTitle(Common.LocalizedStringForKey("SDRefreshViewWillRefreshNomalStateText"), forState: MJRefreshState.Idle)
        header.setTitle(Common.LocalizedStringForKey("SDRefreshViewWillRefreshStateText"), forState: MJRefreshState.Pulling)
        header.stateLabel.textColor = UIColor.lightGrayColor()
        tableView.mj_header = header
    }
    
    /**
    安装上拉刷新
    
    - parameter tableView:
    - parameter target:
    - parameter action:
    */
    static func setupRefreshFoot(tableView: UITableView, target: AnyObject, action: Selector) {
        
        var footer = MJRefreshAutoNormalFooter(refreshingTarget: target, refreshingAction: action)
        footer.stateLabel.textColor = UIColor.lightGrayColor()
        footer.setTitle(Common.LocalizedStringForKey(""), forState: MJRefreshState.Idle)
        footer.setTitle(Common.LocalizedStringForKey(""), forState: MJRefreshState.Pulling)
        footer.setTitle(Common.LocalizedStringForKey("SDRefreshViewLoadMoreingStateText"), forState: MJRefreshState.Refreshing)
        footer.setTitle("", forState: MJRefreshState.NoMoreData)
        
        tableView.mj_footer = footer
        
        
    }
   
}
