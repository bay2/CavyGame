//
//  ClassificationTbCell.swift
//  CavyGame
//
//  Created by longjining on 15/8/15.
//  Copyright (c) 2015年 com.lvwenhan. All rights reserved.
//

import UIKit

class ExUITapGestureRecognizer : UITapGestureRecognizer{
    var index : Int = 0;
}

class ClassificationTbCell: UITableViewCell {

    @IBOutlet weak var gameClassName: UILabel!
    @IBOutlet var itemView : UIView!
    @IBOutlet weak var allBtn: UIButton!
    
    var itemVCs = [ClassItemVC]()
    
    var classSubInfo : ClassificationSunInfo!
    var itemCount : Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        allBtn.setTitle(Common.LocalizedStringForKey("allBtn"), forState: UIControlState.allZeros)
        // Initialization code
    }

    @IBAction func showAll(sender : AnyObject?){
        
        if self.classSubInfo == nil{
            return
        }
        let viewController = Common.rootViewController

        var acVc = ClassAllItemTbVC()
        acVc.gameClassID = classSubInfo.classid
        acVc.title = self.classSubInfo.classname
        
        
        viewController.homeViewController!.navigationController?.pushViewController(acVc, animated: true)
    }
    
    func getItemCount()->(Int, CGFloat){
        
        // 获取一行显示的游戏数量,间隔
        switch resolution() {
            
        case .UIDeviceResolution_iPhoneRetina47 :
            return (3, 25.0)
            
        case .UIDeviceResolution_iPhoneRetina55 :
            return (4, 15.0)
        case .UIDeviceResolution_iPadStandard:
            return (5, 15.0)
        case .UIDeviceResolution_iPadRetina:
            return (5, 15.0)
           
        case .UIDeviceResolution_iPhoneRetina4 :
            return (3, 20.0)
            
        default:
            return (3, 25.0)
        }
    }
    
    func addItemView(classSubInfo : ClassificationSunInfo){
        
        
        self.classSubInfo = classSubInfo
        
        self.gameClassName.text = classSubInfo.classname
        var x : CGFloat = 0;
        var itemVC : ClassItemVC;
        var frame : CGRect;
        var xSpace : CGFloat
        
        var newNibName : String = Common.getResourceAdaptiveName("ClassItemVC")

        
        switch resolution() {
            
        case .UIDeviceResolution_iPhoneRetina4 :
            newNibName = "ClassItemVC_iPhone4"
            
        case .UIDeviceResolution_iPadRetina :
            newNibName = "ClassItemVC_iPadRetina"
            
        case .UIDeviceResolution_iPadStandard :
            newNibName = "ClassItemVC_iPadRetina"
            
        default:
            newNibName = Common.getResourceAdaptiveName("ClassItemVC")
        }
        
        (itemCount, xSpace) = getItemCount()
        
        for subView in self.itemView.subviews{
            subView.removeFromSuperview()
        }
        
        self.itemVCs.removeAll()
        for i in 0...itemCount - 1 {
            
            if i > classSubInfo.gameList.count - 1 {
                return
            }

            itemVC = ClassItemVC(nibName: newNibName, bundle : nil)
            
            frame = itemVC.view.frame
            
            frame.size.width = (Common.screenWidth - xSpace * CGFloat((itemCount + 1)))/CGFloat(itemCount);
            frame.origin.x = CGFloat(i) * frame.width + CGFloat(i + 1) * xSpace;
            
            itemVC.view.frame = frame
            
            //itemVC.view.frame.size.height = self.frame.height - 69
            
            itemVC.setItemInfo(classSubInfo.gameList[i].gameSubInfo)
            
            self.itemView.addSubview(itemVC.view)
            
            itemVC.down.addTarget(self, action: "onClickDown:", forControlEvents:UIControlEvents.TouchUpInside)
            
            itemVCs.append(itemVC)
        }
        
    }
    
//    // 按钮，icon，cell事件响应，屏蔽响应
//    func nofityShowLeftView(notification:NSNotification){
//        removeGesturRec()
//    }
//    
//    func nofityShowHomeView(notification:NSNotification){
//        addGesturRec()
//    }
//    
//    func addGesturRec(){
//        
//        for i in 0...itemCount - 1 {
//            self.itemVCs[i].iconBtn.enabled = true
//            self.itemVCs[i].down.enabled = true
//        }
//    }
//    
//    func removeGesturRec(){
//        
//        for i in 0...itemCount - 1 {
//            self.itemVCs[i].iconBtn.enabled = false
//            self.itemVCs[i].down.enabled = false
//        }
//    }
    
    @IBAction func onClickDown(sender : AnyObject){
        
        var btn = sender as! DownloadWithProgressButton
        btn.clickDownBtn();
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected{
          //  showAll(nil)
        }
         // Configure the view for the selected state
    }
    
}
