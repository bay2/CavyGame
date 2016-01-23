//
//  PrefecturListViewController.swift
//  CavyGame
//
//  Created by xuemincai on 15/9/4.
//  Copyright (c) 2015年 com.lvwenhan. All rights reserved.
//

import UIKit

class PrefecturListViewController: UIViewController {
    
    @IBOutlet weak var prefectureListTable: UITableView!
    var preId : Int!
    var pagenum = 1
    let pagesize = 10
    var prefectureListData : PrefectureListData = PrefectureListData()
    var styleType : String?
    var style : Dictionary<String, AnyObject>?
    var prefectureInfoHight : CGFloat = 10

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Common.setExtraCellLineHidden(prefectureListTable)
        prefectureListTable.separatorStyle = UITableViewCellSeparatorStyle.None
        
        prefectureListTable.dataSource = self
        prefectureListTable.delegate = self
        
        loadStyle()
        
        var color = style?["color"] as? Dictionary<String, AnyObject>
        
        var viewStyle = color!["view"]  as! Dictionary<String, AnyObject>
        var backgroundColor = viewStyle["background"] as! String
        
        view.backgroundColor = UIColor(hexString: backgroundColor)
        
        MJRefreshAdapter.setupRefreshHeader(prefectureListTable, target: self, action: "refrshHeader")
        MJRefreshAdapter.setupRefreshFoot(prefectureListTable, target: self, action: "refreshFoot")
        
        loadGameListData(1, pagesize: pagesize)
        
        loadBackgroundColor()
        
    }
    
    func refrshHeader() {
        loadGameListData(1, pagesize: pagenum * pagesize)
    }
    
    func refreshFoot() {
        pagenum++
        loadGameListData(pagenum, pagesize: pagenum * pagesize)
    }
    
    func loadBackgroundColor() {
        
        loadStyle()
        
        var color = style?["color"] as? Dictionary<String, AnyObject>
        
        var viewStyle = color!["view"]  as! Dictionary<String, AnyObject>
        var backgroundColor = viewStyle["background"] as! String
        
        prefectureListTable.backgroundColor = UIColor(hexString: backgroundColor)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /**
    加载风格
    */
    func loadStyle() {
        
        var styleDate = NSArray(contentsOfFile: NSBundle.mainBundle().pathForResource("PrefectureStyle.plist", ofType: nil)!)
        
        
        for var i = 0; i < styleDate?.count; i++ {
            
            var styleTmp = styleDate![i] as? Dictionary<String, AnyObject>
            
            if  styleTmp!["style"] as! String == styleType! {
                
                style = styleTmp
                
            }
        }
    }
    
    /**
    加载数据
    */
    func loadGameListData(pagenum : Int, pagesize : Int) {
        
        if true == Down_Interface().isNotReachable() {
            
            FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(Common.rootViewController.view, withTitle: Common.LocalizedStringForKey("net_err"), delayTime: Common.alertDelayTime)
            
            self.prefectureListTable.mj_header?.endRefreshing()
            self.prefectureListTable.mj_footer?.endRefreshing()
            
            return
        }
        
        if true == Down_Interface().isNotReachable() {
            
            FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(Common.rootViewController.view, withTitle: Common.LocalizedStringForKey("net_err"), delayTime: Common.alertDelayTime)
            self.prefectureListTable.mj_header?.endRefreshing()
            self.prefectureListTable.mj_footer?.endRefreshing()
            return
        }
        
        HttpHelper<PrefectureListRet>.prefectureList(preId, pagenum: pagenum, pagesize: pagesize) { (result) -> () in
            
            dispatch_async(dispatch_get_main_queue(), {
                
                if let code = result?.code {
                
                    if "1001" != code {
                        self.prefectureListTable.mj_header?.endRefreshing()
                        self.prefectureListTable.mj_footer?.endRefreshing()
                        return
                    }
                }
            
                if let data = result?.data {
                
                
                    if self.prefectureListData.gamelist.count < self.pagesize {
                        self.prefectureListTable.mj_footer = nil
                    }
                
                    self.prefectureListData.bannerphone = data.bannerphone
                    self.prefectureListData.intro = data.intro
                    self.prefectureListData.style = data.style
                    self.prefectureListData.title = data.title
                
                    self.prefectureListTable.mj_header?.endRefreshing()
                    self.prefectureListTable.mj_footer?.endRefreshing()
                    self.prefectureListTable.mj_footer = nil
                    
                    if self.pagenum != 1 {
                       self.prefectureListData.gamelist =  self.prefectureListData.gamelist + data.gamelist
                    } else {
                       self.prefectureListData.gamelist =  data.gamelist
                    }
                
                    self.prefectureListTable.reloadData()
                
                }
                
            })
            
        }
        
    }
    
    /**
    点击返回
    
    :param: sender 
    */
    @IBAction func onClickBack(sender: UIBarButtonItem) {
        
        self.navigationController?.popViewControllerAnimated(true)
        
    }
    
}

extension PrefecturListViewController : UITableViewDataSource, UITableViewDelegate {
    
    func getPrefectureInfoText(text : NSString) -> Float {
        
        return Float(prefectureInfoHight)
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var num = 0
        
        if prefectureListData.bannerphone != nil {
            num++
        }
        
        if prefectureListData.intro != nil {
            num++
        }
        
        return prefectureListData.gamelist.count + num
        
    }
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell : UITableViewCell?
        
        switch indexPath.row {
        case 0:
            var imageCell = tableView.dequeueReusableCellWithIdentifier("prefectureListImage", forIndexPath: indexPath) as! PrefectureListImageTableViewCell
            
            imageCell.preImage.sd_setImageWithURL(NSURL(string: prefectureListData.bannerphone!))
            self.title = prefectureListData.title
            imageCell.bannreMask.image = UIImage(named: "bannre_mengban\(styleType!)");
            
            imageCell.selectionStyle = UITableViewCellSelectionStyle.None
            
            cell = imageCell
            
        case 1:
            var prefectureInfoCell = tableView.dequeueReusableCellWithIdentifier("prefectureListInfo", forIndexPath: indexPath) as? PrefectureInfoTableViewCell
            
            prefectureInfoCell?.prefectureTitle.text = prefectureListData.title
            prefectureInfoCell?.setPrefectureInfoText(prefectureListData.intro!)
            prefectureInfoCell?.selectionStyle = UITableViewCellSelectionStyle.None
            
            prefectureInfoCell?.setNeedsUpdateConstraints()
            prefectureInfoCell?.updateConstraints()
            
            prefectureInfoCell?.updateConstraintsIfNeeded()
            
            prefectureInfoHight = prefectureInfoCell!.prefectureInfo.frame.maxY + 21
            
            
            cell = prefectureInfoCell
            
        default:
            
            var cellGameInfo = tableView.dequeueReusableCellWithIdentifier("GameInfoTableViewCellid", forIndexPath: indexPath) as! GameInfoTableViewCell
            
            var itemInfo = prefectureListData.gamelist[indexPath.row - 2]
            
            cellGameInfo.icon.layer.masksToBounds = true
            cellGameInfo.icon.layer.cornerRadius = Common.iconCornerRadius
            cellGameInfo.icon.sd_setImageWithURL(NSURL(string: itemInfo.icon!))
            cellGameInfo.title.text = itemInfo.gamename
            cellGameInfo.sizeAndDownCnt.text = itemInfo.filesize! + "M"
            cellGameInfo.detail.text = itemInfo.gamedesc
            
            cell = cellGameInfo
            
        }
        
        return setCellStyle(cell!, cellForRowAtIndexPath: indexPath)
        
    }
    
    /**
    设置cell风格
    
    :param: cell
    :param: indexPath
    
    :returns:
    */
    func setCellStyle(cell : UITableViewCell, cellForRowAtIndexPath indexPath: NSIndexPath)-> UITableViewCell {
        
        var color = style?["color"] as? Dictionary<String, AnyObject>
        
        if color == nil {
            
            return cell
            
        }
        
        var viewStyle = color!["view"]  as! Dictionary<String, AnyObject>
        var backgroundColor = viewStyle["background"] as! String
        var halvingline = color!["halvingline"] as! String
        var gradientColor = color!["gradient"] as! String
        var titleLabelColor = color!["title_label"]  as! String
        var detailLabelColor = color!["detail_label"]  as! String
        
        
        
        switch indexPath.row {
            case 0:
                break
                
//                var imageCell = cell  as! PrefectureListImageTableViewCell
//                UIImageView.addShadowWithColor(UIColor(hexString: gradientColor), color2: UIColor(hexString: backgroundColor), inImageView: imageCell.preImage)
//                
//                imageCell.selectionStyle = UITableViewCellSelectionStyle.None
//                prefectureListTable.backgroundColor = UIColor(hexString: backgroundColor)
            
            case 1:
                
                var prefectureInfoCell = cell as! PrefectureInfoTableViewCell
                
                prefectureInfoCell.prefectureTitle.textColor = UIColor(hexString: titleLabelColor)
                prefectureInfoCell.prefectureInfo.textColor = UIColor(hexString: detailLabelColor)
                prefectureInfoCell.halvingline.backgroundColor = UIColor(hexString: halvingline)

            
            default:
            
                var cellGameInfo = cell  as! GameInfoTableViewCell
                cellGameInfo.down.style = style
                cellGameInfo.halvingline.backgroundColor = UIColor(hexString: halvingline)
                cellGameInfo.backgroundColor = UIColor(hexString: backgroundColor)
                cellGameInfo.title.textColor = UIColor(hexString: titleLabelColor)
                cellGameInfo.detail.textColor = UIColor(hexString: detailLabelColor)
                cellGameInfo.sizeAndDownCnt.textColor = UIColor(hexString: detailLabelColor)
                var itemInfo = prefectureListData.gamelist[indexPath.row - 2]
                cellGameInfo.itemInfo = itemInfo

                var view_bg : UIView = UIView()
                view_bg.backgroundColor = UIColor(hexString: gradientColor)
                cellGameInfo.selectedBackgroundView = view_bg

                cellGameInfo.norBkColor = UIColor(hexString: backgroundColor)
                cellGameInfo.highlightedBkColor = UIColor(hexString: gradientColor)
            
        }

        
        cell.backgroundColor = UIColor(hexString: backgroundColor)
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        switch indexPath.row {
            
        case 0:
            return Common.screenWidth / (7 / 3)
            
        case 1:
            return CGFloat(getPrefectureInfoText(prefectureListData.intro!))
            
        default:
            
            if .UIDeviceResolution_iPhoneRetina4 == resolution() {
                
                return 85
                
            }
            
            return 121
            
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
        if indexPath.row < 2 {
            return
        }
        
        var gameVc = Common.getViewControllerWithIdentifier("AppInfo", identifier: "AppInfoView") as! AppInfoViewController
        
        gameVc.gameId = prefectureListData.gamelist[indexPath.row - 2].gameid!
        
        self.navigationController?.pushViewController(gameVc, animated: true)
        
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
}
