//
//  RankTableView.swift
//  
//
//  Created by Jessica on 16/1/25.
//
//

import UIKit

class RankTableView: UITableView {
    
    var currPage      = 1// 下拉加载当前页
    let pageSize      = 10// 每页获取的数目
    var rankType      = String()
    var rankListArray = Array<RankList>()

    var btn_blogPage : String       = ""
    var gameListInfo : GameListInfo = GameListInfo()

    
    func loadData(){
    
        // 加载第一页
        HttpHelper<GameListInfo>.getRankingList(1, ranktype: self.rankType, pagesize: pageSize * currPage, completionHandlerRet:{(result) -> () in
            
            if result == nil{
                dispatch_async(dispatch_get_main_queue(), {
                    self.mj_header?.endRefreshing()
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
                    self.reloadData()
                    self.mj_header?.endRefreshing()
                })
                self.updateVersion()
            }
        })
        if true == Down_Interface().isNotReachable() {
            
            FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(self, withTitle: Common.LocalizedStringForKey("net_err"), delayTime: Common.alertDelayTime)
            return
        }
    }
    
    // 下拉刷新
    func headerRefresh(){

        self.loadData()
        
    }
    
    // 上拉加载
    func footerRefresh(){

        //loadMoreData()
        if true == Down_Interface().isNotReachable() {

            FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(self, withTitle: Common.LocalizedStringForKey("net_err"), delayTime: Common.alertDelayTime)
            self.mj_footer?.endRefreshing()
            return
        }
        
        self.currPage++
        HttpHelper<GameListInfo>.getRankingList(currPage, ranktype: rankType, pagesize: pageSize, completionHandlerRet:{(result) -> () in
            
            if result == nil{
                
            }else{
                let gamesInfo : GameListInfo = result!
                if self.gameListInfo.gameList.count == 0 {
                    self.gameListInfo = gamesInfo
                }else{
                    
                    if gamesInfo.pageNum == nil || gamesInfo.pageNum < self.currPage {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.mj_footer?.endRefreshing()
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
                    self.mj_footer?.endRefreshing()
                    self.reloadData()
                })
            }
        })
        
        
    }

    // 移除
    func removeFooterRefresh(){
        
        self.mj_footer = nil
        
    }
    
    func updateVersion(){
        
        for item in self.gameListInfo.gameList{
            if (item.gameSubInfo != nil){
                DownloadManager.getInstance().needUpdate(item.gameSubInfo.gameid, version: item.gameSubInfo.version, downUrl : item.gameSubInfo.downurl)
            }
        }
    }
}
