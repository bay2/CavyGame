//
//  SearchViewController.swift
//  CavyGame
//
//  Created by xuemincai on 15/8/17.
//  Copyright (c) 2015年 com.lvwenhan. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

    @IBOutlet weak var searchTableView: UITableView!
    @IBOutlet weak var searchText: UITextField!
    @IBOutlet weak var reminderLable: UILabel!
    var gameInfoCellHight : CGFloat = 0.0
    var tapbackgroundTap : UITapGestureRecognizer?
    
    
    var isSearchGame = false
    var gameList : Array<GameInfo> = Array<GameInfo>()
        var hotKeyArray : Array<String> = Array<String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // 隐藏多余分割线
        var view = UIView()
        view.backgroundColor = UIColor.clearColor()
        
        searchTableView.tableFooterView = view
        searchTableView.tableHeaderView = view
        searchText.placeholder = Common.LocalizedStringForKey("searchGame")
        
        //代理 tableview
        searchTableView.dataSource = self
        searchTableView.delegate = self
        
        searchText.delegate = self
        
        if Common.getDeviceIosVersion() >= 7 {
            
            searchText.tintColor = UIColor.blueColor()
            
        }
        
        if (8.0 <= Common.getDeviceIosVersion()) {
            
            //使分割线靠最左边
            searchTableView.layoutMargins = UIEdgeInsetsZero
            
        }
        
        tapbackgroundTap = UITapGestureRecognizer(target: self, action: "backgroundTap:")
        
        searchTableView.separatorInset = UIEdgeInsetsZero
        
        searchTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        if .UIDeviceResolution_iPhoneRetina4 == resolution() {
            
            searchTableView.registerNib(UINib(nibName: "GameInfoTableViewCell_iPhone4", bundle:nil), forCellReuseIdentifier: "GameInfoTableViewCellid")
            
        } else {
            
            searchTableView.registerNib(UINib(nibName: "GameInfoTableViewCell", bundle:nil), forCellReuseIdentifier: "GameInfoTableViewCellid")
        }
        
        
        
        searchTableView.separatorInset = UIEdgeInsetsZero
        
        HttpHelper<HotKeyRet>.getHotKey { (result) -> () in
            
            if "1001" != result?.code {
                
                return
                
            }
            
            self.hotKeyArray = result!.data!.hotkey!
            
            dispatch_async(dispatch_get_main_queue(),{
                self.searchTableView.reloadData()
                })
            
        }
        
        // Do any additional setup after loading the view.
    }
    
    func backgroundTap(tg : UITapGestureRecognizer) {
        
        searchText.resignFirstResponder()
        searchTableView.removeGestureRecognizer(tapbackgroundTap!)
        
    }
    
    /**
    点击搜索
    
    :param: sender
    */
    @IBAction func OnClickSearch(sender: UIBarButtonItem) {
        
        searchGame(searchText.text)
    }
    
    /**
    点击返回
    
    :param: sender <#sender description#>
    */
    @IBAction func onClickBack(sender: UIBarButtonItem) {
        
        searchText.resignFirstResponder()
        
        if isSearchGame {
            
            isSearchGame = false
            searchText.text = ""
            reminderLable.hidden = true
            searchTableView.reloadData()
            return
        }
        
        Common.rootViewController.homeViewController.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    /**
    搜索游戏
    
    :param: gameName 游戏名
    */
    func searchGame(gameName : String) {
        
        reminderLable.hidden = true
        searchText.resignFirstResponder()
        searchTableView.removeGestureRecognizer(tapbackgroundTap!)
        
        HttpHelper<SearchGameRet>.searchGame(gameName, completionHandlerRet: { (result) -> () in
            
            if "1001" != result?.code {
                return
            }
            
            self.gameList = result!.data!.gameList
            self.isSearchGame = true
            
            dispatch_async(dispatch_get_main_queue(),{
                self.searchTableView.reloadData()
                
                if 0 == self.gameList.count {
                    
                    self.reminderLable.hidden = false
                    self.reminderLable.text = result!.msg!
                    
                }
                
            })
            
        })
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

// MARK: - TableView 代理处理
extension SearchViewController : UITableViewDataSource, UITableViewDelegate{
    
    /**
    cell 个数
    
    :param: tableView <#tableView description#>
    :param: section   <#section description#>
    
    :returns: <#return value description#>
    */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isSearchGame {
            return gameList.count
        }
        
        return hotKeyArray.count
    }
    
    /**
    创建cell
    
    :param: tableView
    :param: indexPath
    
    :returns: <#return value description#>
    */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if false == isSearchGame {
            
            var cell = tableView.dequeueReusableCellWithIdentifier("HotKeyCell", forIndexPath: indexPath) as! HotKeyTableViewCell
            
            if (0 != hotKeyArray.count) {
                cell.title?.text = hotKeyArray[indexPath.row]
            }
            
            //使分割线靠最左边
            if (8.0 <= Common.getDeviceIosVersion()) {
                
                cell.layoutMargins = UIEdgeInsetsZero
            }
            
            return cell
            
        } else {
            
            var cell = tableView.dequeueReusableCellWithIdentifier("GameInfoTableViewCellid", forIndexPath: indexPath) as! GameInfoTableViewCell
            
            var itemInfo = gameList[indexPath.row].gameSubInfo
            
            cell.icon.sd_setImageWithURL(NSURL(string: itemInfo.icon!))
            cell.icon.layer.masksToBounds = true
            cell.icon.layer.cornerRadius = Common.iconCornerRadius
            cell.title.text = itemInfo.gamename
            cell.sizeAndDownCnt.text = itemInfo.filesize! + "M"
            cell.detail.text = itemInfo.gamedesc
            cell.down.hidden = true
            
            gameInfoCellHight = cell.frame.height
            
            //使分割线靠最左边
            if (8.0 <= Common.getDeviceIosVersion()) {
                
                cell.layoutMargins = UIEdgeInsetsZero
            }
            
            return cell
            
        }
        
    }
    
    /**
    设置tableview 行高
    
    :param: tableView <#tableView description#>
    :param: indexPath <#indexPath description#>
    
    :returns: <#return value description#>
    */
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if isSearchGame {
            
            if .UIDeviceResolution_iPhoneRetina4 == resolution() {
                
                return 93.5
                
            } else {
                return 129.0
            }
            
            
        }
        
        return 55
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if false == isSearchGame {
            
            searchGame(hotKeyArray[indexPath.row])
            
        } else {
            
            var appInfoVc = Common.getViewControllerWithIdentifier("AppInfo", identifier: "AppInfoView")  as! AppInfoViewController
            
            appInfoVc.gameId = gameList[indexPath.row].gameSubInfo.gameid!
            appInfoVc.itemInfo = gameList[indexPath.row].gameSubInfo

            Common.rootViewController.homeViewController.navigationController?.pushViewController(appInfoVc, animated: true)
            
            
        }
        
        searchText.resignFirstResponder()
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    
}

// MARK: - TextField 代理处理
extension SearchViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        searchGame(textField.text)
        
        
        return true
        
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
        searchTableView.addGestureRecognizer(tapbackgroundTap!)
    }
    
}
