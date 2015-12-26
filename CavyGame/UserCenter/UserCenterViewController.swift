//
//  UserCenterViewController.swift
//  CavyGame
//
//  Created by xuemincai on 15/8/7.
//  Copyright (c) 2015年 com.lvwenhan. All rights reserved.
//

import UIKit

struct SelectLoacl {
    var selectProvince:Int!
    var selectCity:Int!
}

class UserCenterViewController: UIViewController {

    var cellIdentifier:Array<String> = ["avatarCell",
        "nikeNameCell",
        "genderCell",
        "birthdayCell",
        "localCell"]
    
    @IBOutlet weak var localPicker: UIPickerView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var genderPicker: UIPickerView!
    @IBOutlet weak var userCenterTableView: UITableView!
    @IBOutlet weak var bottomBtn: UIButton!
    

    var selectProvinceIndex = SelectLoacl()
    var userCenterControl = UserCenter()
    var selectTableCellRow : NSIndexPath?
    var genderIndex : Int!
    var avatarCell : AvatarTableViewCell?
    var nikeNameCell : NikeNameTableViewCell?
    @IBOutlet var userCenterView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = Common.LocalizedStringForKey("usercenter")
        
        userCenterControl.loadUserInfo { (bLoadRet) -> () in
            
            if UserCenterLoadStat.LoadUserSucceed == bLoadRet {
                dispatch_async(dispatch_get_main_queue(), {
                    self.userCenterTableView.reloadData()
                })
            }
        }
        
        //tableview 代理
        userCenterTableView.delegate = self
        userCenterTableView.dataSource = self
        
        //PickerView 代理
        localPicker.dataSource = self
        localPicker.delegate = self
        genderPicker.dataSource = self
        genderPicker.delegate = self
        
        //加载地址数据
        selectProvinceIndex.selectCity = 0
        selectProvinceIndex.selectProvince = 0

        
        userCenterTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        //隐藏多余的分割线
        Common.setExtraCellLineHidden(userCenterTableView)

        setBottomButtonText(Common.LocalizedStringForKey("usercenterView_logout_btn"))

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
    点击界面底部按钮
    
    :param: sender 
    */
    @IBAction func OnClickBottom(sender: UIButton) {
        
        if Common.LocalizedStringForKey("usercenterView_logout_btn") == sender.titleLabel?.text { //注销处理
            
            var actionSheetView = ALActionSheetView.showActionSheetWithTitle("", cancelButtonTitle: Common.LocalizedStringForKey("cancel_text"), destructiveButtonTitle: "", otherButtonTitles: [Common.LocalizedStringForKey("usercenterView_logout_btn")], handler: { (actionSheetView1, buttonIndex) -> Void in
                
                if buttonIndex == 0 {
                    
                    Common.rootViewController.leftViewController.Userlogout()
                    Common.rootViewController.showLeft()
                    Common.rootViewController.leftViewController.avatarBtn.setImage(UIImage(named: "avatar"), forState: UIControlState.Normal)
                    
                    Common.userInfo.userid = -1
                    
                }
                
            }, handlerInit: { (actionSheetView1, buttonIndex) -> Void in
                
                actionSheetView1.setTitleColor(UIColor.redColor(), forState: UIControlState.Normal)
                
            })
            
            actionSheetView.show()
            
        } else { //保存处理
            
            if (selectTableCellRow != nil) {
                
                saveInfoShouldBegin()

            }
            
           var loadingView = FVCustomAlertView.shareInstance.showDefaultLoadingAlertOnView(self.view, withTitle: Common.LocalizedStringForKey("send_userinfo"), isClickDisappeared: true)
            
            userCenterControl.updateUserInfo({ (updateRet, msg) -> () in
                
                FVCustomAlertView.shareInstance.hideAlert(loadingView!)
                
                if (true == updateRet) {
                
                    Common.rootViewController.leftViewController.userName.text = self.nikeNameCell?.nikeName.text
                
                } else {
                    
                    if msg != nil {
                        
                        FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(self.view, withTitle: msg!, delayTime: Common.alertDelayTime)
                        
                    } else {
                        
                        FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(self.view, withTitle: Common.LocalizedStringForKey("net_err"), delayTime: Common.alertDelayTime)
                        
                    }
                    
                }
            })
            
            setBottomButtonText(Common.LocalizedStringForKey("usercenterView_logout_btn"))
        }
    }
    
    
    /**
    保存用户信息前处理
    */
    func saveInfoShouldBegin() {
        
        if "localCell" == cellIdentifier[selectTableCellRow!.row] {
            
            var provinceRow = localPicker.selectedRowInComponent(0)
            var cityRow = localPicker.selectedRowInComponent(1)
            let cell = userCenterTableView.cellForRowAtIndexPath(selectTableCellRow!)
            var localLabel = cell!.viewWithTag(1) as! UILabel
            
            
            localLabel.text = userCenterControl.getProvince(provinceRow) + " " + userCenterControl.getCity(provinceRow, row: cityRow)
            userCenterControl.strComefrom = userCenterControl.getProvince(provinceRow) + "-" + userCenterControl.getCity(provinceRow, row: cityRow)
            localPicker.hidden = true
            
        }
        
        if "birthdayCell" == cellIdentifier[selectTableCellRow!.row] {
            
            var dBirthday = datePicker.date
            var dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            let cell = userCenterTableView.cellForRowAtIndexPath(selectTableCellRow!)
            
            var birthdayLabel = cell!.viewWithTag(1) as! UILabel
            
            
            birthdayLabel.text = dateFormatter.stringFromDate(dBirthday)
            userCenterControl.strBirthday = birthdayLabel.text!
            
            datePicker.hidden = true
            
        }
        
        
        if "genderCell" == cellIdentifier[selectTableCellRow!.row] {
            
            let cell = userCenterTableView.cellForRowAtIndexPath(selectTableCellRow!)
            userCenterControl.iGender = genderPicker.selectedRowInComponent(0)
            
            var genderLabel = cell!.contentView.viewWithTag(1) as! UILabel
            
            if nil != userCenterControl.iGender {
                genderLabel.text = userCenterControl.arrayGender[userCenterControl.iGender!]
            }
            
            genderPicker.hidden = true
        }
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


// MARK: - tableView 代理处理
extension UserCenterViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier[indexPath.row], forIndexPath: indexPath) as! UITableViewCell
        
        switch (cellIdentifier[indexPath.row]) {
            
        case "avatarCell":
            
            var titleLabel = cell.contentView.viewWithTag(2) as! UILabel
            titleLabel.text = Common.LocalizedStringForKey("usercenter_title1")
            
            
            avatarCell = cell as? AvatarTableViewCell
            avatarCell!.avatarImage.sd_setImageWithURL(NSURL(string: userCenterControl.strAvatarUrl))
            
            avatarCell!.avatarImage.layer.masksToBounds = true
            avatarCell!.avatarImage.layer.cornerRadius  = avatarCell!.avatarImage.bounds.size.width * 0.5

            break
            
        case "nikeNameCell":
            
//            var titleLabel = cell.contentView.viewWithTag(2) as! UILabel
//            titleLabel.text = Common.LocalizedStringForKey("usercenter_title2")
            
            nikeNameCell = cell as? NikeNameTableViewCell
            nikeNameCell!.nikeName.text = userCenterControl.nikename
            nikeNameCell?.delegate = self
            break
            
        case "genderCell":
            
            var titleLabel = cell.contentView.viewWithTag(2) as! UILabel
            titleLabel.text = Common.LocalizedStringForKey("usercenter_title3")
            
            if userCenterControl.loadData == UserCenterLoadStat.LoadUserSucceed {
                var genderLabel = cell.contentView.viewWithTag(1) as! UILabel
                
                genderLabel.text = userCenterControl.arrayGender[userCenterControl.iGender!]
                
                genderPicker.selectRow(userCenterControl.iGender!, inComponent: 0, animated: false)
                
            }
            
        case "birthdayCell":
            
            var titleLabel = cell.contentView.viewWithTag(2) as! UILabel
            titleLabel.text = Common.LocalizedStringForKey("usercenter_title4")
            
            var birthdayLabel = cell.viewWithTag(1) as! UILabel
            
            if userCenterControl.loadData == UserCenterLoadStat.LoadUserSucceed {
                
                cell.detailTextLabel?.hidden = false
                
                
                if "" == userCenterControl.strBirthday {
                    
                    userCenterControl.strBirthday = "1990-01-01"
                    
                }
                
                var dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                
                datePicker.setDate(dateFormatter.dateFromString(userCenterControl.strBirthday)!, animated: false)
                
                birthdayLabel.text = userCenterControl.strBirthday
                
            }
            
        case "localCell":
            
            var titleLabel = cell.contentView.viewWithTag(2) as! UILabel
            titleLabel.text = Common.LocalizedStringForKey("usercenter_title5")
            
            var localLabel = cell.viewWithTag(1) as! UILabel
            localLabel.text = userCenterControl.getProvince(userCenterControl.userProvinceIndex) + " " + userCenterControl.getCity(userCenterControl.userProvinceIndex, row: userCenterControl.userCityIndex)
            localPicker.selectRow(userCenterControl.userProvinceIndex, inComponent: 0, animated: false)
            localPicker.selectRow(userCenterControl.userCityIndex, inComponent: 1, animated: false)
            localPicker.reloadComponent(1)
            selectProvinceIndex.selectProvince = userCenterControl.userProvinceIndex
            selectProvinceIndex.selectCity = userCenterControl.userCityIndex
            
        default:
            break
        }
        
        return cell
    }
    
    /**
    设置cell高度
    
    :param: tableView 视图
    :param: indexPath 索引
    
    :returns: 高度
    */
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if  "avatarCell" == cellIdentifier[indexPath.row] {
            
            if .UIDeviceResolution_iPhoneRetina4 == resolution() {
                
                return 79
                
            }
            
            return 92
        }
        
        if .UIDeviceResolution_iPhoneRetina4 == resolution() {
            
            return 48
            
        }
        
        return 53
    }
    
    func hiddenKeyboard() {
        
        
        let cell = userCenterTableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as! NikeNameTableViewCell
        
        cell.nikeName.resignFirstResponder()
    }
    
    /**
    系统通知行被选中 －－ 代理
    
    :param: tableView table视图对象
    :param: indexPath 行索引
    */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
        if ("nikeNameCell" != cellIdentifier[indexPath.row]) {
            
            hiddenKeyboard()
            
        }
        
        //使用选择的行恢复默认状态
        switch cellIdentifier[indexPath.row] {
            case "avatarCell":
                
                localPicker.hidden = true
                datePicker.hidden = true
                genderPicker.hidden = true
                
                var actionSheetView = ALActionSheetView.showActionSheetWithTitle("", cancelButtonTitle : Common.LocalizedStringForKey("cancel_text"), destructiveButtonTitle: "", otherButtonTitles: [Common.LocalizedStringForKey("usercenter_photo1"), Common.LocalizedStringForKey("usercenter_photo2")], handler: { (actionSheetView1, buttonIndex) -> Void in
                    
                        if buttonIndex == 0 {
                    
                            var imagePicker = UIImagePickerController()
                            imagePicker.delegate  = self
                            imagePicker.allowsEditing = true
                            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                            self.presentViewController(imagePicker, animated: true, completion: nil)
                    
                        }
                    
                        if buttonIndex == 1 {
                    
                            var imagePicker = UIImagePickerController()
                            imagePicker.delegate  = self
                            imagePicker.allowsEditing = true
                            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
                                            self.presentViewController(imagePicker, animated: true, completion: nil)
                                        
                        }
                    
                    
                })
                
                actionSheetView.show()

                break
            
            case "nikeNameCell":
                localPicker.hidden = true
                datePicker.hidden = true
                genderPicker.hidden = true
            
                break
            
            case "genderCell":
                localPicker.hidden = true
                datePicker.hidden = true
                genderPicker.hidden = false
                setBottomButtonText(Common.LocalizedStringForKey("usercenterView_save_btn"))
            
            case "birthdayCell":
                localPicker.hidden = true
                datePicker.hidden = false
                genderPicker.hidden = true
                setBottomButtonText(Common.LocalizedStringForKey("usercenterView_save_btn"))
            
            case "localCell":
                localPicker.hidden = false
                datePicker.hidden = true
                genderPicker.hidden = true
                setBottomButtonText(Common.LocalizedStringForKey("usercenterView_save_btn"))
            
            default:
                break
        }
        
        selectTableCellRow = indexPath
        
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
 
    /**
    设置底部按钮文字
    
    :param: text 文字
    */
    func setBottomButtonText(text:String) {
        
        if (Common.LocalizedStringForKey("usercenterView_save_btn") == text) {
            
            bottomBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            bottomBtn.setBackgroundCoclor(UIColor(hexString: "4cd864"), forState: UIControlState.Normal)
            bottomBtn.setBackgroundCoclor(UIColor(hexString: "15c233"), forState: UIControlState.Highlighted)
            
        } else {
            bottomBtn.setTitleColor(UIColor(hexString: "353535"), forState: UIControlState.Normal)
            bottomBtn.setBackgroundCoclor(UIColor(hexString: "dadada"), forState: UIControlState.Normal)
            bottomBtn.setBackgroundCoclor(UIColor(hexString: "b7b7b7"), forState: UIControlState.Highlighted)
            
        }
        
        bottomBtn.setTitle(text, forState: UIControlState.Normal)
        
    }
    
}

// MARK: - PickerView 代理处理
extension UserCenterViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    /**
    PickerView 列数
    
    :param: pickerView 视图
    
    :returns: 列数
    */
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        
        if pickerView == localPicker {
            return 2
        } else if pickerView == genderPicker {
            return 1
        } else {
            return 0
        }

    }
    
    // returns the # of rows in each component..
    /**
    配置选择行个数
    
    :param: pickerView 视图
    :param: component  列
    
    :returns: 行个数
    */
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if pickerView == localPicker { //地址picker
            
                switch (component) {
                case 0:
                    return userCenterControl.getProvinceNum()
                
                case 1:
                    return userCenterControl.getCityNum(selectProvinceIndex.selectProvince)
                
                default:
                    return  0;
            }
            
        } else if pickerView == genderPicker { //性别picker
            
            return 2
            
        } else {
            return 0
        }
    }
    
    /**
    PickerView 加载数据
    
    :param: pickerView 视图
    :param: row        行
    :param: component  列
    
    :returns: 显示数据
    */

    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        
        if localPicker == pickerView { //地址picker
            
                switch (component) {
                case 0:
                    return userCenterControl.getProvince(row)
                
                case 1:
                    var strCity = userCenterControl.getCity(selectProvinceIndex.selectProvince, row: row)
                    if "" == strCity {
                        localPicker.reloadComponent(1)
                    }
                    return strCity

                default:
                    return  ""
                }
        } else if genderPicker == pickerView { //性别picker
            
            return userCenterControl.arrayGender[row]
        } else {
            return ""
        }
    }
    
    @IBAction func onClickBack(sender: UIBarButtonItem) {
        
        self.navigationController?.popViewControllerAnimated(true)
        
    }
    
    /**
    picker 选择中后处理
    
    :param: pickerView 视图
    :param: row        行
    :param: component  列
    */
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if localPicker == pickerView { //地区选择处理
            
            switch (component) {
            case 0:
                selectProvinceIndex.selectProvince = row
                localPicker.selectRow(component, inComponent: component + 1, animated: true)
                localPicker.reloadComponent(component + 1)
            case 1:
                selectProvinceIndex.selectCity = row
                
            default:
                return
            }
        }
        
        return
        
    }
}

// MARK: - UIImagePickerController 代理处理
extension UserCenterViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //保存图片至沙盒
    func saveImage(currentImage: UIImage, newSize: CGSize, percent: CGFloat, imageName: String){
            //压缩图片尺寸
        UIGraphicsBeginImageContext(newSize)
        currentImage.drawInRect(CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        //高保真压缩图片质量
        //UIImageJPEGRepresentation此方法可将图片压缩，但是图片质量基本不变，第二个参数即图片质量参数。
        let imageData: NSData = UIImageJPEGRepresentation(newImage, percent)
        // 获取沙盒目录,这里将图片放在沙盒的documents文件夹中
        let fullPath: String = NSHomeDirectory().stringByAppendingPathComponent("Documents").stringByAppendingPathComponent(imageName)
        // 将图片写入文件
        imageData.writeToFile(fullPath, atomically: false)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        var mediaType: NSString = info[UIImagePickerControllerMediaType] as! String;
        
        if (mediaType.isEqualToString("public.image")) {
            
            var avatarImageUrl : NSURL?
            var image : UIImage?
            
            if picker.allowsEditing {
                
                image = info[UIImagePickerControllerEditedImage] as? UIImage
                
                self.saveImage(image!, newSize: CGSize(width: 256, height: 256), percent: 0.5, imageName: "currentImage.png")
                var fullPath = NSHomeDirectory().stringByAppendingPathComponent("Documents").stringByAppendingString("currentImage.png")
                
                avatarImageUrl = NSURL(string: fullPath)
                
                
            } else {
                image = info[UIImagePickerControllerOriginalImage] as? UIImage
                avatarImageUrl  = info[UIImagePickerControllerReferenceURL] as? NSURL
            }
            
            
            let FVCustomView = FVCustomAlertView.shareInstance.showDefaultLoadingAlertOnView(Common.rootViewController.view, withTitle: Common.LocalizedStringForKey("send_photo"), isClickDisappeared: false)
            
            userCenterControl.updateAvatar(image, imageName: avatarImageUrl!.lastPathComponent, updateProc: { (result) -> () in
                
                dispatch_async(dispatch_get_main_queue(),{
                
                    if true == result {
                    
                        self.avatarCell?.avatarImage.image = image
                        
                        Common.rootViewController.leftViewController.avatarBtn.setImage(image, forState: UIControlState.Normal)
                        FVCustomAlertView.shareInstance.hideAlert(FVCustomView!)
                        
                    } else {
                    
                        FVCustomAlertView.shareInstance.hideAlert(FVCustomView!)
                    
                        FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(Common.rootViewController.view, withTitle: Common.LocalizedStringForKey("net_err"), delayTime: Common.alertDelayTime)
                    
                    }
                })
            })
            
        } else {
            
            println("Error media type")
            
        }
        
        picker.dismissViewControllerAnimated(true, completion: nil)

    }
    

}

extension UserCenterViewController : NikeNameDelegate {
    
    func textFieldShouldReturn(textField: UITextField) {
        
        userCenterControl.nikename = textField.text!
        
        var loadingView = FVCustomAlertView.shareInstance.showDefaultLoadingAlertOnView(self.view, withTitle: Common.LocalizedStringForKey("send_userinfo"), isClickDisappeared: true)
        
        userCenterControl.updateUserInfo({ (updateRet, msg) -> () in
            
            FVCustomAlertView.shareInstance.hideAlert(loadingView!)
            
            if (true == updateRet) {
                
                Common.rootViewController.leftViewController.userName.text = self.nikeNameCell?.nikeName.text
                
            } else {
                
                if msg != nil {
                    
                    FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(self.view, withTitle: msg!, delayTime: Common.alertDelayTime)
                    
                } else {
                    
                    FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(self.view, withTitle: Common.LocalizedStringForKey("net_err"), delayTime: Common.alertDelayTime)
                    
                }
                
            }
        })
        
    }
    
    
    
}


