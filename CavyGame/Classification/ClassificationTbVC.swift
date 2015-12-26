//
//  ClassificationTbVC.swift
//  CavyGame
//
//  Created by longjining on 15/8/15.
//  Copyright (c) 2015年 com.lvwenhan. All rights reserved.
//

import UIKit

class ClassificationTbVC: RefreshTableViewController {

    var classDataInfo : ClassificationInfo = ClassificationInfo()
    let cellID = "ClassificationTbCellid"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()

        switch resolution() {
            
        case .UIDeviceResolution_iPhoneRetina4 :
            self.tableView.registerNib(UINib(nibName: "ClassificationTbCell_iPhone4", bundle:nil), forCellReuseIdentifier: cellID)
            
        case .UIDeviceResolution_iPadRetina :
            self.tableView.registerNib(UINib(nibName: "ClassificationTbCell_iPadRetina", bundle:nil), forCellReuseIdentifier: cellID)
            
        case .UIDeviceResolution_iPadStandard :
            self.tableView.registerNib(UINib(nibName: "ClassificationTbCell_iPadRetina", bundle:nil), forCellReuseIdentifier: cellID)
        default:
            self.tableView.registerNibExt("ClassificationTbCell", identifier:cellID)
        }
    
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        setSpaceHeadView()
        
        loadData()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "nofityShowLeftView:", name: Common.notifyShowLeftView, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "nofityShowHomeView:", name: Common.notifyShowHomeView, object: nil)
        
        setupRefreshHeader()
    }

    override func headerRefresh(){
        
        self.loadData()
        super.headerRefresh()
    }
    
    func nofityShowHomeView(notification:NSNotification){
        
        self.tableView.allowsSelection = true
        self.tableView.scrollEnabled = true
    }
    
    func nofityShowLeftView(notification:NSNotification){
        
        self.tableView.allowsSelection = false
        self.tableView.scrollEnabled = false
    }
    
    func setSpaceHeadView(){
        var headerView = UIView(frame: CGRectMake(0.0, 0.0,
            Common.screenWidth,
            Common.controlTopSpace))
        headerView.backgroundColor = Common.tableBackColor
        self.tableView.tableHeaderView = headerView
    }
    
    func loadData(){
        
        if true == Down_Interface().isNotReachable() {
            
            FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(self.view, withTitle: Common.LocalizedStringForKey("net_err"), delayTime: Common.alertDelayTime)
            
            if nil != self.refreshHeader {
                
                self.refreshHeader!.endRefreshing()
                
            }
            
            return
        }
        
        HttpHelper<ClassificationInfo>.getClassInfo ({(result) -> () in
            
            if result == nil{
                
            }else{
                self.classDataInfo = result!
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                })
                self.updateVersion()
                NSNotificationCenter.defaultCenter().postNotificationName(Common.notifyLoadFinishData, object:nil)
            }
        })
    }
    
    func updateVersion(){
        
        for item in self.classDataInfo.classListSubInfo{
            for itemSub in item.gameList{
                
                if !(itemSub.gameSubInfo.gameid?.isEmpty != nil){
                    DownloadManager.getInstance().needUpdate(itemSub.gameSubInfo.gameid, version: itemSub.gameSubInfo.version, downUrl : itemSub.gameSubInfo.downurl)
                }
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getItemHight()->CGFloat{
        
        // 获取一行显示的游戏数量,间隔
        switch resolution() {
            
        case .UIDeviceResolution_iPhoneRetina47 :
            return 268.0
            
        case .UIDeviceResolution_iPhoneRetina55 :
            
            return 242.0
        case .UIDeviceResolution_iPadStandard:
            return 333.0
        case .UIDeviceResolution_iPadRetina:
            return 333.0
        case .UIDeviceResolution_iPhoneRetina4 :
            return 224.0
            
        default:
            return 289.0
        }
    }
}


// MARK: - Table view data source

extension ClassificationTbVC : UITableViewDataSource, UITableViewDelegate{
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self.classDataInfo.classListSubInfo.count
    }
    override
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        var cell = tableView.dequeueReusableCellWithIdentifier(cellID, forIndexPath: indexPath) as! ClassificationTbCell


        //使分割线靠最左边
        if (8.0 <= Common.getDeviceIosVersion()) {
            
            cell.layoutMargins = UIEdgeInsetsZero
        }
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.addItemView(self.classDataInfo.classListSubInfo[indexPath.row])
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        
        return getItemHight()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        //使用选择的行恢复默认状态
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
}
