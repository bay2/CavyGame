//
//  RecommendationVC.swift
//  CavyGame
//  推荐功能
//  Created by longjining on 15/8/10.
//  Copyright (c) 2015年 com.lvwenhan. All rights reserved.
//

import UIKit

class RecommendationVC : GameListBaseTableViewController {

    var headerbanner1View : CNAutoScrollView!
    var headerbanner2Btn1 : UIButton!
    var headerbanner2Btn2 : UIButton!

    var tapGesture1: UITapGestureRecognizer!
    var tapGesture2: UITapGestureRecognizer!

    let imgCornerRadius : CGFloat = Common.bannerRadius

    let controlSpace : CGFloat = 10/2  // 控件间的间隔
    
    var banner1Hight : CGFloat = 0
    
    private let defultImg = "banner_2"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        btn_blogPage = Common.notifyAdd_Page1
        
        initHeardView()

        MJRefreshAdapter.setupRefreshHeader(self.tableView, target: self, action: "headerRefresh")
        loadData()

        if (8.0 <= Common.getDeviceIosVersion()) {
            
            //使分割线靠最左边
            self.tableView.layoutMargins = UIEdgeInsetsZero
        }
        
        self.tableView.registerNib(UINib(nibName: "GameInfoImgTableViewCell", bundle:nil), forCellReuseIdentifier: "GameInfoImgTableViewCellid")
    }
    
    override func headerRefresh(){
        
        self.loadData()
        super.headerRefresh()
    }
    
    func initHeardView(){
        banner1Hight = (Common.screenWidth - controlSpace * 2) * 3/7  // 宽度－两边的间隔 * 3/7
        let banner2Hight : CGFloat = (Common.screenWidth - controlSpace * 2) * 2/7  // 宽度－两边的间隔 * 2/7
        let banner2ImgWidth : CGFloat = (Common.screenWidth - controlSpace * 3)/2
        
        headerbanner1View = CNAutoScrollView(frame: CGRectMake(controlSpace, Common.controlTopSpace,
            self.view.bounds.width - controlSpace * 2,
            banner1Hight))
        
        headerbanner1View!.delegate = self
        headerbanner1View!.autoScroll = true
        headerbanner1View!.backgroundColor = UIColor.whiteColor()
        headerbanner1View.layer.borderWidth = 0.6
        headerbanner1View.layer.borderColor = UIColor(hexString: "BBBBBB")?.CGColor
        
        // img1
        headerbanner2Btn1 = UIButton(frame: CGRectMake(controlSpace,
            Common.controlTopSpace + banner1Hight + controlSpace,
            banner2ImgWidth,
            banner2Hight))
        headerbanner2Btn1.setImage(UIImage(named: defultImg), forState: UIControlState.Normal)
        headerbanner2Btn1.addTarget(self, action: "handleTap:", forControlEvents: UIControlEvents.TouchUpInside)
        headerbanner2Btn1.tag = 0
        headerbanner2Btn1.layer.borderWidth = 0.6
        headerbanner2Btn1.layer.borderColor = UIColor(hexString: "BBBBBB")?.CGColor
        
        // img2
        headerbanner2Btn2 = UIButton(frame: CGRectMake(controlSpace * 2 + banner2ImgWidth,
            Common.controlTopSpace + banner1Hight + controlSpace,
            banner2ImgWidth,
            banner2Hight))
        headerbanner2Btn2.setImage(UIImage(named: defultImg), forState: UIControlState.Normal)
        headerbanner2Btn2.addTarget(self, action: "handleTap:", forControlEvents: UIControlEvents.TouchUpInside)
        headerbanner2Btn2.tag = 1
        headerbanner2Btn2.layer.borderWidth = 0.6
        headerbanner2Btn2.layer.borderColor = UIColor(hexString: "BBBBBB")?.CGColor
        
        var headerView = UIView(frame: CGRectMake(0.0, 0.0,
            self.view.bounds.width,
            Common.controlTopSpace + banner1Hight + controlSpace + banner2Hight + controlSpace))
        
        // 设置圆角
        headerbanner1View.layer.masksToBounds = true;
        headerbanner1View.layer.cornerRadius = self.imgCornerRadius

        headerbanner2Btn1.layer.masksToBounds = true;
        headerbanner2Btn1.layer.cornerRadius = self.imgCornerRadius

        headerbanner2Btn2.layer.masksToBounds = true;
        headerbanner2Btn2.layer.cornerRadius = self.imgCornerRadius

        headerView.addSubview(headerbanner1View)
        headerView.addSubview(headerbanner2Btn1)
        headerView.addSubview(headerbanner2Btn2)
        headerView.backgroundColor = Common.tableBackColor
        
        self.tableView.tableHeaderView = headerView
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "nofityShowLeftView:", name: Common.notifyShowLeftView, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "nofityShowHomeView:", name: Common.notifyShowHomeView, object: nil)

        addGesturRec()
    }
    
    func nofityShowLeftView(notification:NSNotification){
        removeGesturRec()
    }
    
    func nofityShowHomeView(notification:NSNotification){
        addGesturRec()
    }
    
    func addGesturRec(){
        
        headerbanner2Btn1.enabled = true
        headerbanner2Btn2.enabled = true
        self.tableView.scrollEnabled = true
        self.tableView.allowsSelection = true

    }
    
    func removeGesturRec(){
        
        headerbanner2Btn1.enabled = false
        headerbanner2Btn2.enabled = false

        self.tableView.scrollEnabled = false
        self.tableView.allowsSelection = false
    }

    //处理图片点击事件
    func handleTap(sender : AnyObject){

        // 显示专栏
        
        var btn = sender as! UIButton
        
        if btn.tag >= self.gameListInfo.recomd2Game.count {
            return
        }
        
        var gameType = self.gameListInfo.recomd2Game[btn.tag].type
        
        if gameType == nil{
            return
        }
        if gameType == GameType.prefecture.rawValue{
            
            self.showPrefecture(self.gameListInfo.recomd2Game[btn.tag].gameid!.toInt()!, prefectureStyle:self.gameListInfo.recomd2Game[btn.tag].style!)
        }else{
            showGameDetail(self.gameListInfo.recomd2Game[btn.tag].gameid!, gameSubInfo : GameSubInfo())
        }
    }
    
    override func loadData(){
        
        if true == Down_Interface().isNotReachable() {
            
            FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(self.view, withTitle: Common.LocalizedStringForKey("net_err"), delayTime: Common.alertDelayTime)
            self.tableView.mj_header.endRefreshing()
            return
        }
        
        weak var weakSelf = self as RecommendationVC;
        
        HttpHelper<GameListInfo>.getRecommendatonList { (result) -> () in
            
            if result == nil{
                
            }else{
                
                if 0 == result?.gameList.count {
                    return
                }
                
                weakSelf!.gameListInfo = result!
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    if weakSelf!.gameListInfo.gameList.count > 0{
                        weakSelf!.tableView.reloadData()
                        weakSelf!.headerbanner1View.reloadImage()
                    }
                    
                    if weakSelf!.gameListInfo.recomd2Game[0].images != nil {
                        weakSelf!.headerbanner2Btn1.sd_setImageWithURL(NSURL(string: self.gameListInfo.recomd2Game[0].images!), forState: UIControlState.Normal, placeholderImage: UIImage(named: self.defultImg))
                    }
                    if weakSelf!.gameListInfo.recomd2Game[1].images != nil {
                        weakSelf!.headerbanner2Btn2.sd_setImageWithURL(NSURL(string: self.gameListInfo.recomd2Game[1].images!), forState: UIControlState.Normal, placeholderImage: UIImage(named: self.defultImg))
                    }
                    
                    self.tableView.mj_header.endRefreshing()
                })
                weakSelf!.updateVersion()
                NSNotificationCenter.defaultCenter().postNotificationName(Common.notifyLoadFinishData, object:nil)
            }
        }
    }
    
    func showPrefecture(prefectureID : Int, prefectureStyle : String){
        
        // 显示专题
        
        var preListVc : PrefecturListViewController!
        
        switch resolution() {
            
        case .UIDeviceResolution_iPhoneRetina4:
            preListVc = UIStoryboard(name: "Prefecture_iPhone4", bundle: nil).instantiateViewControllerWithIdentifier("PrefectureListView") as! PrefecturListViewController
            
        case .UIDeviceResolution_iPadRetina:
            preListVc = UIStoryboard(name: "Prefecture_iPadRetina", bundle: nil).instantiateViewControllerWithIdentifier("PrefectureListView") as! PrefecturListViewController
            
        case .UIDeviceResolution_iPadStandard:
            preListVc = UIStoryboard(name: "Prefecture_iPadRetina", bundle: nil).instantiateViewControllerWithIdentifier("PrefectureListView") as! PrefecturListViewController
            
        default:
            preListVc = Common.getViewControllerWithIdentifier("Prefecture", identifier: "PrefectureListView") as! PrefecturListViewController
            
        }
        
        
        preListVc.preId = prefectureID
        preListVc.styleType = prefectureStyle
        
        self.navigationController?.pushViewController(preListVc, animated: true)
    }
}

extension RecommendationVC : CNAutoScrollViewDelegate{
    
    func numbersOfPages()->Int{
        
        return gameListInfo.banners.count;
    }
    
    func imageNameOfIndex(index: Int) -> String!{
       
        return gameListInfo.banners[index].image
    }
    
    func didSelectedIndex(index: Int){
        
        if self.gameListInfo.banners.count > 0{
            
            if self.gameListInfo.banners[index].type == "prefecture" {
                
                showPrefecture(self.gameListInfo.banners[index].gameid!.toInt()!, prefectureStyle: self.gameListInfo.banners[index].style!)
                
            } else if self.gameListInfo.banners[index].type == "notice" {
                
                var noticeDetail = Common.getViewControllerWithIdentifier("Notice", identifier: "NoticeDetail") as! NoticeDetailViewController
                
                noticeDetail.navigationItem.title = self.gameListInfo.banners[index].title!
                noticeDetail.loadhttp = self.gameListInfo.banners[index].url
                
                self.navigationController?.pushViewController(noticeDetail, animated: true)
                
            } else {
                showGameDetail(self.gameListInfo.banners[index].gameid, gameSubInfo : GameSubInfo())
                
            }
        }
    }
}

extension RecommendationVC {
    
    override
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        if 0 == self.gameListInfo.gameList.count {
            
            var cell = tableView.dequeueReusableCellWithIdentifier("GameInfoImgTableViewCellid", forIndexPath: indexPath) as! GameInfoImgTableViewCell
            
     
            return cell;
            
        }
        
        var gameType = self.gameListInfo.gameList[indexPath.row].gameType
        
        if gameType == GameType.prefecture.rawValue{
            // 专区
            var cell = tableView.dequeueReusableCellWithIdentifier("GameInfoImgTableViewCellid", forIndexPath: indexPath) as! GameInfoImgTableViewCell
            
            //使分割线靠最左边
            if (8.0 <= Common.getDeviceIosVersion()) {
                
                cell.layoutMargins = UIEdgeInsetsZero
            }
            
            var gameInfoItem = self.gameListInfo.gameList[indexPath.row].prefectureSubInfo
            
            if gameInfoItem == nil{
                return cell;
            }
            cell.prefectureInfo = gameInfoItem
            
            cell.specialTopicBtn.sd_setImageWithURL(NSURL(string: gameInfoItem.bannerphone!), forState: UIControlState.Normal, placeholderImage: UIImage(named: "banner_1"))
            
            cell.specialTopicBtn.layer.masksToBounds = true;
            cell.specialTopicBtn.layer.cornerRadius = Common.bannerRadius
            cell.specialTopicBtn.layer.borderWidth = 0.6
            cell.specialTopicBtn.layer.borderColor = UIColor(hexString: "BBBBBB")?.CGColor
            
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell
        }else{
            // 普通游戏
           return super.tableView(tableView, cellForRowAtIndexPath :indexPath)
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        
        if 0 == self.gameListInfo.gameList.count {
            return 0
        }
        
        var gameType = self.gameListInfo.gameList[indexPath.row].gameType

        if gameType == GameType.prefecture.rawValue{
            
            return banner1Hight + 9
            
        }else{
            
            if .UIDeviceResolution_iPhoneRetina4 == resolution() {
                
                return 93.5
                
            }
            
            return 129.0
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        //使用选择的行恢复默认状态
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        var gameType = self.gameListInfo.gameList[indexPath.row].gameType
        
        if gameType == GameType.prefecture.rawValue{
            // 显示专题
           // self.showPrefecture(self.gameListInfo.gameList[indexPath.row].prefectureSubInfo.prefectureId!, prefectureStyle:self.gameListInfo.gameList[indexPath.row].prefectureSubInfo.style!)
            return
        }else{
            showGameDetail(gameListInfo.gameList[indexPath.row].gameSubInfo.gameid!, gameSubInfo : gameListInfo.gameList[indexPath.row].gameSubInfo)
        }
    }
}