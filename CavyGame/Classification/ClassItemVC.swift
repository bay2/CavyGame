//
//  ClassItemVC.swift
//  CavyGame
//
//  Created by longjining on 15/8/15.
//  Copyright (c) 2015年 com.lvwenhan. All rights reserved.
//

import UIKit

class ClassItemVC: UIViewController {

    @IBOutlet weak var iconBtn: UIButton!
    @IBOutlet weak var gameTitle: UILabel!
    @IBOutlet weak var gameSize: UILabel!
    @IBOutlet weak var down: DownloadWithProgressButton!
    var itemInfo : GameSubInfo!{
        didSet{
            down.itemInfo = itemInfo
        }
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?){
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "nofityShowLeftView:", name: Common.notifyShowLeftView, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "nofityShowHomeView:", name: Common.notifyShowHomeView, object: nil)
        
    }
    
    func nofityShowLeftView(notification:NSNotification){
        iconBtn.enabled = false
        down.enabled = false
    }
    
    func nofityShowHomeView(notification:NSNotification){
        iconBtn.enabled = true
        down.enabled = true
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.down.setButtonImageStatus(DownBtnStatus_OC.STATUS_Down)
        self.down.initBnt()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setItemInfo(itemInfo : GameSubInfo){
        
        self.down.whichPage = Common.notifyAdd_Page3
        self.itemInfo = itemInfo
        self.gameTitle.text = itemInfo.gamename
        
        self.gameSize.text = itemInfo.filesize! + "M"
        
        self.iconBtn.sd_setImageWithURL(NSURL(string: itemInfo.icon!), forState: UIControlState.Normal, placeholderImage: UIImage(named: "icon_game"))
        // 设置圆角
        self.iconBtn.layer.masksToBounds = true;
        self.iconBtn.layer.cornerRadius = Common.iconCornerRadius
    }

    @IBAction func onClickBtn(sender : UIButton){
        
        if itemInfo == nil{
            return
        }
        
        showGameDetail(itemInfo.gameid, gameSubInfo : itemInfo)
    }
    
    func showGameDetail(gameID : String!, gameSubInfo : GameSubInfo){
        
        
        var appInfoVc = Common.getViewControllerWithIdentifier("AppInfo", identifier: "AppInfoView") as! AppInfoViewController
        
        appInfoVc.gameId = gameID
        appInfoVc.itemInfo = gameSubInfo
        
        Common.rootViewController.homeViewController.navigationController?.pushViewController(appInfoVc, animated: true)
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
