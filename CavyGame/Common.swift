//
//  Common.swift
//  CavyGame
//
//  Created by JohnLui on 15/4/11.
//  Copyright (c) 2015年 com.lvwenhan. All rights reserved.
//

import UIKit

struct UserInfo {
    var avatar : String?            //用户头像
    var birthday : String?          //生日
    var email : String?             //邮箱
    var gender : String?            //性别
    var is_disabled : Bool?
    var last_login_time : String?   //最后登录时间
    var nikename : String?          //匿名
    var phone : String?             //手机号码
    var userid : Int?               //用户id
    var username : String?          //用户名
    var usertoken : String?         //用户token
    
    init() {
        userid = -1
        usertoken = "-1"
    }
}

struct DownBtnStatus_OC {
    // 下载状态（与oc参数）
    static let STATUS_Down : NSInteger = 1001    // 下载、继续
    static let STATUS_Finish : NSInteger = 1002  // 安装、打开
    static let STATUS_Pause : NSInteger = 1003   // 暂停、重试
}

// 下载状态 0 下载 1 暂停 2 成功 3失败 4更新
struct DownBtnStatus {
    static let STATUS_Init   : NSInteger = -1
    static let STATUS_Ready   : NSInteger = 0
    static let STATUS_Down   : NSInteger = 1
    static let STATUS_Pause  : NSInteger = 2
    static let STATUS_Succ   : NSInteger = 3
    static let STATUS_Faild  : NSInteger = 4
    static let STATUS_Update : NSInteger = 5
}

struct Common {
    
    
    static let M_SIZE  = 1048576.0
    static let phonetype = "ios"
    static let controlTopSpace : CGFloat = 9/2  // 表格顶部间的间隔
    static let iconCornerRadius : CGFloat = 12 // icon的圆角
    
    static var bannerRadius : CGFloat {
        
        get {
            if .UIDeviceResolution_iPhoneRetina4 == resolution() {
                
                return 7
                
            } else {
                
                return 12
                
            }
        }
        
    }
    
    static var btnCornerRadius : CGFloat {
        get {
            if .UIDeviceResolution_iPhoneRetina4 == resolution() {
                
                return 4
                
            } else {
                
                return 6
                
            }
        }
    }
    static let alertDelayTime : Double = 2 //提示框消失时间
    
    static let cellSetHighlightedBkColor = UIColor(hexString: "#d0d0d0") // 通用的背景
    static let tableBackColor = UIColor(hexString: "#eeeeee") // 通用的背景
    static let TitleBarColor = UIColor(hexString : "#3e76db") // titlebar颜色
    static let currentPageIndicatorTintColor = UIColor(hexString : "#ffffff") // pagecontrol当前页颜色
    static let pageIndicatorTintColor = UIColor(hexString : "#8284a3") // pagecontrol其它页颜色
    
    static let notifyShowLeftView = "notify_showLeftView"
    static let notifyShowHomeView = "notify_showhomeView"
    static let notifyLoadFinishData = "notify_loadFinishData"
    static let notifyShowView = "showNotificationView"
    static let notifyAPNSShowView = "showAPNSShowAlertView"

    // 按钮所属页面识别（推荐 排行 分类）
    static let notifyAdd_Page1 = "page1"
    static let notifyAdd_Page2 = "page2"
    static let notifyAdd_Page3 = "page3"
    static let notifyRemove_PrePage = "remove"


    static var userInfo = UserInfo()
    static let screenWidth = UIScreen.mainScreen().applicationFrame.maxX
    static let screenHeight = UIScreen.mainScreen().applicationFrame.maxY
    static let rootViewController = UIApplication.sharedApplication().keyWindow?.rootViewController as! ViewController
//    static let contactsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Contacts") as! UIViewController
    
    static let contactsVC = Common.getViewControllerWithIdentifier("Main", identifier: "Contacts") as! UIViewController
    
    static func LocalizedStringForKey(key: String) -> String
    {
        return NSBundle.mainBundle().localizedStringForKey(key, value:"", table: "")
    }
    
    static func userID()->String{
    
        let id = String(format: "%d", userInfo.userid!)
        return id
    }
    /**
    校验联系方式是否是邮箱
    
    :param: strEmall 联系方式
    
    :returns: 是 － true，否 － false
    */
    static func isEmall(strEmall : String) -> Bool {
        
        if strEmall.isEmpty {
            return false
        }
        
        return Regex("([a-zA-Z0-9_-])+@([a-zA-Z0-9_-])+(.[a-zA-Z0-9_-])+").test(strEmall)
        
    }
    
    /**
    校验联系方式是否是电话号码
    
    :param: num 联系方式
    
    :returns: 是 - ture, 否 － false
    */
    static func isTelNumber(num : String) -> Bool {
        
        if num.isEmpty {
            return false
        }
        
        var strNum = count(num)
        
        if  11 != strNum {
            return false
        }
        
        for c in num{
            if c != "0" && c != "1" && c != "2" && c != "3" && c != "4" && c != "5" && c != "6" && c != "7" && c != "8" && c != "9" {
                return false
            }
        }
        
        return true
    }
    
    /**
    获取系统语言
    
    :returns: 系统语言 中文－zh，其他－en
    */
    static func getPreferredLanguage() -> String {
        var defaults = NSUserDefaults.standardUserDefaults()
        var allLanguages: AnyObject? = defaults.objectForKey("AppleLanguages")
        var preferredLang: AnyObject? = allLanguages?.objectAtIndex(0)
        var lan = allLanguages?.objectAtIndex(0) as! String
       
        if "zh-Hans" <= lan {
            return "zh"
        } else if "zh-Hant" <= lan {
            return "zh_tw"
        } else if "zh-HK" <= lan {
            return "zh_tw"
        } else if "ja" <= lan {
            return "ja"
        }
        
        return "en"
    }
    
    /**
    隐藏多余的分割线
    
    :param: tableView table视图
    */
    static func setExtraCellLineHidden(tableView : UITableView) {
        
        var view = UIView()
        
        view.backgroundColor = UIColor.clearColor()
        
        tableView.tableFooterView = view
        tableView.tableHeaderView = view
        
    }
    
    /**
    获取ios系统版本号
    
    :returns: 版本号
    */
    static func getDeviceIosVersion() -> Float!{
        return (UIDevice.currentDevice().systemVersion as NSString).floatValue
    }
    
    /**
    根据状态码获取对应的文字
    
    :returns: 状态码对应的文字
    */
    static func getStaByCode(sta : NSInteger) -> String!{
        
        switch sta{
        case DownBtnStatus.STATUS_Down:
            return Common.LocalizedStringForKey("pause")
        case DownBtnStatus.STATUS_Ready:
            return Common.LocalizedStringForKey("pause")
        case DownBtnStatus.STATUS_Pause:
            return Common.LocalizedStringForKey("downcontinue")
        case DownBtnStatus.STATUS_Succ:
            return Common.LocalizedStringForKey("install")
        case DownBtnStatus.STATUS_Faild:
            return Common.LocalizedStringForKey("download_again")
        case DownBtnStatus.STATUS_Update:
            return Common.LocalizedStringForKey("download_update")
        default:
            return Common.LocalizedStringForKey("down")
       }
    }
    
    /**
    保存图片
    
    :param: tempImage 图片
    :param: imageName 图片文件名
    */
    static func saveImage(tempImage : UIImage!, WithName imageName : String!)
    {
        var imageData = UIImagePNGRepresentation(tempImage)
        
        var paths = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)
        
        var documentsDirectory : NSString = paths[0] as! NSString
        
        // Now we get the full path to the file
        var fullPathToFile = documentsDirectory.stringByAppendingPathComponent(imageName)
        
        // and then we write it out
        imageData.writeToFile(fullPathToFile, atomically: false)
    }
    
    /**
    压缩图片
    
    :param: image   图片
    :param: newSize 新的大小
    
    :returns: 压缩后的图片
    */
    static func imageWithImageSimple (image : UIImage!, newSize : CGSize!) -> UIImage {
        
        UIGraphicsBeginImageContext(newSize);
        
        image.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
        
        var newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext();
        
        return  newImage;
    }
    
    /**
    获取适配资源名称
    
    :param: resourceName 资源名称
    
    :returns:
    */
    static func getResourceAdaptiveName(resourceName : String) -> String {
        
        var newResourceName = resourceName
        
        switch resolution() {
            
        case .UIDeviceResolution_iPhoneRetina47 :
            break
            
        case .UIDeviceResolution_iPhoneRetina55 :
            newResourceName = resourceName + "_iPhone55"
            break
            
        case .UIDeviceResolution_iPhoneRetina4 :
           break
            
        default:
            break
            
        }
        
        return newResourceName
        
    }
    
    /**
    获取故事板资源
    
    :param: storyboardName 故事板名称
    :param: identifier
    
    :returns:
    */
    static func getViewControllerWithIdentifier(storyboardName : String, identifier : String) -> AnyObject! {
        
        var newStoryboardName = getResourceAdaptiveName(storyboardName)
        
        return UIStoryboard(name: newStoryboardName, bundle: nil).instantiateViewControllerWithIdentifier(identifier)
    }
}



// MARK: - 扩展计算字符大小
extension NSString {
    
    func textSizeWithFont(font: UIFont, constrainedToSize size:CGSize) -> CGSize {
        var textSize:CGSize!
        if CGSizeEqualToSize(size, CGSizeZero) {
            let attributes = NSDictionary(object: font, forKey: NSFontAttributeName)
            textSize = self.sizeWithAttributes(attributes as [NSObject : AnyObject])
        } else {
            let option = NSStringDrawingOptions.UsesLineFragmentOrigin
            let attributes = NSDictionary(object: font, forKey: NSFontAttributeName)
            let stringRect = self.boundingRectWithSize(size, options: option, attributes: attributes as [NSObject : AnyObject], context: nil)
            textSize = stringRect.size
        }
        return textSize
    }
}

extension String {
    
    func md5() -> String {
        
        return MyMD5.md5(self)
        
    }
    
    
}

extension UIButton {
    
    func DrawImageFromColor(coclor : UIColor) -> UIImage {
        
        var rect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)
        
        UIGraphicsBeginImageContext(rect.size)
        var context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, coclor.CGColor)
        CGContextFillRect(context, rect)
        var img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return img
        
    }
    
    /**
    设置图片背景设
    
    :param: color 背景设
    :param: state 状态
    */
    func setBackgroundCoclor(color: UIColor!, forState state: UIControlState) {
        
        self.setBackgroundImage(DrawImageFromColor(color), forState: state)
        
    }
    
}


extension UITableView {
        
    func registerNibExt(nibName: String, identifier : String) {
        
        var newNibName = Common.getResourceAdaptiveName(nibName)
        
        self.registerNib(UINib(nibName: newNibName, bundle:nil), forCellReuseIdentifier: identifier)
        
    }
    
}
