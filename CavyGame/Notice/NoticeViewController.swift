//
//  NoticeViewController.swift
//  CavyGame
//
//  Created by xuemincai on 15/8/31.
//  Copyright (c) 2015年 com.lvwenhan. All rights reserved.
//

import UIKit

class NoticeViewController: UIViewController  {

    @IBOutlet weak var noticeTableView: UITableView!
    var sysMsg : Array<NoticeData> = Array<NoticeData>()
    
    var pagenum = 1
    let pagesize = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        noticeTableView.dataSource = self
        noticeTableView.delegate = self
        self.title = Common.LocalizedStringForKey("main_leftview_title_sysmsg")
        
        
        Common.setExtraCellLineHidden(self.noticeTableView)
        noticeTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        noticeTableView.registerNibExt("NoticeTableViewCell", identifier: "Notice")
        
        MJRefreshAdapter.setupRefreshFoot(noticeTableView, target: self, action: "loadData")
        MJRefreshAdapter.setupRefreshHeader(noticeTableView, target: self, action: "loadData")
        
        loadData()
    
        // Do any additional setup after loading the view.
    }
    
    
    /**
    加载数据
    */
    func loadData() {
        
        //加载公告信息
        
        if true == Down_Interface().isNotReachable() {
            
            FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(Common.rootViewController.view, withTitle: Common.LocalizedStringForKey("net_err"), delayTime: Common.alertDelayTime)
            
            self.noticeTableView.mj_footer?.endRefreshing()
            self.noticeTableView.mj_header?.endRefreshing()
            
            return
        }
        
        HttpHelper<SysAnnouncement>.getNoticeInfo(pagenum, pagesize: pagesize){ (result) -> () in
            
            dispatch_async(dispatch_get_main_queue(), {
            
                if nil == result!.code {
                    self.noticeTableView.mj_footer?.endRefreshing()
                    self.noticeTableView.mj_header?.endRefreshing()
                    return
                }
            
                if "1001" == result!.code! {
                
                    if self.pagesize > result!.data?.count {
                        self.noticeTableView.mj_footer = nil
                    }
                
                    if self.pagenum > 1 {
                        self.sysMsg = self.sysMsg + result!.data!
                        self.pagenum++
                    } else {
                        self.sysMsg = result!.data!
                    }

                    self.noticeTableView.reloadData()
                    
                }
                
                self.noticeTableView.mj_footer?.endRefreshing()
                self.noticeTableView.mj_header?.endRefreshing()
            
            })
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onClickBack(sender: UIBarButtonItem) {
        
        self.navigationController?.popViewControllerAnimated(true)
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension NoticeViewController : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("Notice", forIndexPath: indexPath) as! NoticeTableViewCell
        
        //添加公告信息
        cell.titleLable.text = self.sysMsg[indexPath.row].title
        cell.createTimeLable.text = self.sysMsg[indexPath.row].create_time
        cell.contentLable.text = self.sysMsg[indexPath.row].content
        
        cell.noticeIcon.sd_setImageWithURL(NSURL(string: self.sysMsg[indexPath.row].msgicon!))
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        return sysMsg.count
        
    }
    
    /**
    系统通知行被选中 －－ 代理
    
    :param: tableView table视图对象
    :param: indexPath 行索引
    */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        //使用选择的行恢复默认状态
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        var noticeDetail = Common.getViewControllerWithIdentifier("Notice", identifier: "NoticeDetail") as! NoticeDetailViewController
        
        noticeDetail.navigationItem.title = sysMsg[indexPath.row].title
        noticeDetail.loadhttp = sysMsg[indexPath.row].detia_url
        self.navigationController?.pushViewController(noticeDetail, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath:NSIndexPath) -> CGFloat {
        
        if .UIDeviceResolution_iPhoneRetina4 == resolution() {
            
            return 92
            
        }
        
        return 108
        
    }
    
}
