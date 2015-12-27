//
//  PrefectureViewController.swift
//  CavyGame
//
//  Created by xuemincai on 15/9/3.
//  Copyright (c) 2015年 com.lvwenhan. All rights reserved.
//

import UIKit

class PrefectureViewController: UIViewController {

    @IBOutlet weak var pefectureTable: UITableView!
    
    var pagenum = 1
    let pagesize = 10
    
    var prefectureList = Array<PreList>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pefectureTable.dataSource = self
        pefectureTable.delegate = self
        
        Common.setExtraCellLineHidden(pefectureTable)
        pefectureTable.separatorStyle = UITableViewCellSeparatorStyle.None
        pefectureTable.backgroundColor = Common.tableBackColor
        
        MJRefreshAdapter.setupRefreshFoot(pefectureTable, target: self, action: "loadData")
        MJRefreshAdapter.setupRefreshHeader(pefectureTable, target: self, action: "loadData")
        
        loadData()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "nofityShowLeftView:", name: Common.notifyShowLeftView, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "nofityShowHomeView:", name: Common.notifyShowHomeView, object: nil)
    }
    
    func nofityShowHomeView(notification:NSNotification){
        
        pefectureTable.allowsSelection = true
        pefectureTable.scrollEnabled = true
    }
    
    func nofityShowLeftView(notification:NSNotification){
        
        pefectureTable.allowsSelection = false
        pefectureTable.scrollEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func loadData() {
        
        if true == Down_Interface().isNotReachable() {
            
            FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(self.view, withTitle: Common.LocalizedStringForKey("net_err"), delayTime: Common.alertDelayTime)
            
            self.pefectureTable.mj_footer?.endRefreshing()
            self.pefectureTable.mj_header?.endRefreshing()

            return
        }
        
        HttpHelper<PrefectureInfoRet>.prefectureInfo(pagenum, pagesize: pagesize) { (result) -> () in
            
            dispatch_async(dispatch_get_main_queue(), {
                
                if let code = result?.code {
                
                    if code != "1001" {
                    
                        self.pefectureTable.mj_footer?.endRefreshing()
                        self.pefectureTable.mj_header?.endRefreshing()
                        return
                    }
                }
            
                if let data = result?.data?.preList {
                    
                    if data.count < self.pagesize {
                        self.pefectureTable.mj_footer = nil
                    }
                
                    if self.pagenum > 1 {
                    
                        self.prefectureList = self.prefectureList + data
                        self.pagenum++
                    
                    } else {
                        self.prefectureList = data
                    }

                    self.pefectureTable.reloadData()
                    self.pefectureTable.mj_footer?.endRefreshing()
                    self.pefectureTable.mj_header?.endRefreshing()
                
                }
            })
        }
    }

}

extension PrefectureViewController : UITableViewDataSource, UITableViewDelegate, PrefectureDelegate {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return prefectureList.count
        
    }
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("prefectureCell", forIndexPath: indexPath) as! PrefectureTableViewCell
        
        cell.prefectureBtn.sd_setImageWithURL(NSURL(string: prefectureList[indexPath.row].bannerphone!), forState: UIControlState.Normal, placeholderImage: UIImage(named: "banner_1"))
        cell.backgroundColor = Common.tableBackColor
        cell.prefectureBtn.layer.masksToBounds = true
        cell.prefectureBtn.layer.cornerRadius = Common.bannerRadius
        cell.prefectureBtn.layer.borderWidth = 0.6
        cell.prefectureBtn.layer.borderColor = UIColor(hexString: "BBBBBB")?.CGColor
        cell.prefectureBtn.tag = indexPath.row
        cell.preDelegate = self
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return (Common.screenWidth - 10) / (7 / 3) + 9
        
    }
    
    
    func onClickPre(sender: UIButton) {
        
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
        
        preListVc.preId = prefectureList[sender.tag].prefectureId
        preListVc.styleType = prefectureList[sender.tag].style
        preListVc.navigationItem.title = prefectureList[sender.tag].title
        
        self.navigationController?.pushViewController(preListVc, animated: true)
    }
    
}
