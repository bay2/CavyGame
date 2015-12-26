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
    
    var refreshHeader : SDRefreshHeaderView!
    var refreshFoot : SDRefreshFooterView!
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
        
        loadData()
        
        setupRefreshHeader()
        setupRefreshFoot()

        // Do any additional setup after loading the view.
    }
    
    
    /**
    加载数据
    */
    func loadData() {
        
        //加载公告信息
        
        if true == Down_Interface().isNotReachable() {
            
            FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(Common.rootViewController.view, withTitle: Common.LocalizedStringForKey("net_err"), delayTime: Common.alertDelayTime)
            
            if refreshHeader != nil {
                self.refreshHeader!.endRefreshing()
            }
            
            if refreshFoot != nil {
                self.refreshFoot!.endRefreshing()
            }
            
            return
        }
        
        HttpHelper<SysAnnouncement>.getNoticeInfo(pagenum, pagesize: pagesize){ (result) -> () in
            
            if nil == result!.code {
                return
            }
            
            if "1001" == result!.code! {
                
                if 0 == result!.data?.count {
                    self.removeFooterRefresh()
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    if self.pagenum > 1 {
                        
                        self.sysMsg = self.sysMsg + result!.data!
                        
                        
                    } else {
                        
                        self.sysMsg = result!.data!
                        
                    }
                    
                    self.noticeTableView.reloadData()
                    
                })
            }
            
        }
        
    }
    
    
    func setupRefreshHeader(){
        refreshHeader = SDRefreshHeaderView();
        
        // 默认是在navigationController环境下，如果不是在此环境下，请设置 refreshHeader.isEffectedByNavigationController = NO;
        //  refreshHeader.isEffectedByNavigationController = false
        refreshHeader.addToScrollView(self.noticeTableView)
        
        refreshHeader.addTarget(self, refreshAction:"headerRefresh")
    }
    
    func headerRefresh(){
        
        // 重新请求详情
        
        pagenum = 1
        
        loadData()
        
        self.delay(2.0, closure: { () -> () in
            
            self.refreshHeader.endRefreshing()
        })
        
        if nil == refreshFoot {
            setupRefreshFoot()
        }
        
    }
    
    func setupRefreshFoot(){
        refreshFoot = SDRefreshFooterView();
        
        // 默认是在navigationController环境下，如果不是在此环境下，请设置 refreshHeader.isEffectedByNavigationController = NO;
        //  refreshFoot.isEffectedByNavigationController = false
        refreshFoot.addToScrollView(self.noticeTableView)
        
        refreshFoot.addTarget(self, refreshAction:"footerRefresh")
    }
    
    func footerRefresh(){
        
        // 加载更多评论
        
        pagenum++
        loadData()
        
        self.delay(2.0, closure: { () -> () in
            
            self.refreshFoot.endRefreshing()
        })
        
        
        
    }
    
    func removeFooterRefresh(){
        
        if nil != refreshFoot {
            
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
