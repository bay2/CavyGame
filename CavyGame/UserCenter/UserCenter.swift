//
//  UserCenter.swift
//  CavyGame
//
//  Created by xuemincai on 15/8/9.
//  Copyright (c) 2015年 com.lvwenhan. All rights reserved.
//

import Foundation
import UIKit

enum UserCenterLoadStat{
    case LoadingUserInfo
    case LoadUserSucceed
    case LoadUserError
    case LoadUserHttpError
}


class UserCenter {
    
    //头像
    var strAvatarUrl : String = ""
    
    //头像压缩大小
    let avatarSize : CGSize = CGSize(width: 100, height: 100)
    
    //用户邮箱
    var strEmail : String = ""
    
    //用户是否被禁用
    var is_disabled : Bool = false
    
    //用户最后一次登录时间
    var strLast_login_time : String = ""
    
    //用户手机号码
    var phone : String = ""
    
    //用户名
    var username : String = ""
    
    //地址数据集
    var loaclDate : NSArray!
    
    //性别数据集
    var arrayGender = [Common.LocalizedStringForKey("gender_woman"), Common.LocalizedStringForKey("gender_man")]
    
    //加载数据状态
    var loadData : UserCenterLoadStat = UserCenterLoadStat.LoadingUserInfo
    
    //性别
    var iGender : Int?
    
    //匿名
    var nikename : String = ""
    
    //地区
    var strComefrom : String = ""
    
    //省
    var userProvinceIndex : Int = 0
    
    //城市
    var userCityIndex : Int = 0
    
    //生日
    var strBirthday : String = "1996-01-01"
    
    
    init () {
        
        loaclDate = NSArray(contentsOfFile: NSBundle.mainBundle().pathForResource("city.plist", ofType: nil)!)
    }
    
    /**
    获取省份
    
    :param: row 行id
    
    :returns: 省名称
    */
    func getProvince(row : Int) ->String! {
        
        var province: AnyObject? = loaclDate?.objectAtIndex(row).objectForKey("state")
        return province as! String!
    }
    
    /**
    获取城市
    
    :param: provinceIndex 省份id
    :param: row           行id
    
    :returns: 城市名称
    */
    func getCity(provinceIndex : Int, row : Int) -> String! {
        
        var cities: AnyObject? = loaclDate?.objectAtIndex(provinceIndex).objectForKey("cities")
        
        if (row >= cities!.count!) {
            return ""
        }
        
        var city: AnyObject? = cities?.objectAtIndex(row)
        
        return city as! String!
        
    }
    
    /**
    获取城市个数
    
    :param: provinceIndex 省份
    
    :returns: 城市个数
    */
    func getCityNum(provinceIndex : Int) -> Int! {
        var cities: AnyObject? = loaclDate?.objectAtIndex(provinceIndex).objectForKey("cities")
        return cities!.count!
    }
    
    /**
    获取省份个数
    
    :returns: 省份个数
    */
    func getProvinceNum() -> Int! {
        
        return loaclDate.count
    }
    
    /**
    获取用户头像
    
    :returns: 用户头像
    */
    func getAvatar() -> UIImage! {
        return UIImage(named: "avatar")
    }
    
    /**
    加载用户数据
    
    :param: loadDid 加载完成处理
    */
    func loadUserInfo(loadDid:(bLoadRet : UserCenterLoadStat) -> ()) {
        
        loadData = UserCenterLoadStat.LoadingUserInfo
        
        HttpHelper<UserCenterInfoMsg>.getUserInfo { (result) -> () in
            
            if result == nil {
                self.loadData = UserCenterLoadStat.LoadUserHttpError
                loadDid(bLoadRet: UserCenterLoadStat.LoadUserHttpError)
                
                return
            }
            
            if nil == result?.code {
                
                self.loadData = UserCenterLoadStat.LoadUserHttpError
                loadDid(bLoadRet: UserCenterLoadStat.LoadUserHttpError)
                
                return
                
            }
            
            
            if ("1001" == result!.code!) {
                
                self.strAvatarUrl = result!.data!.avatar!
                self.strBirthday = result!.data!.birthday!
                self.strComefrom = result!.data!.comefrom!
                self.strEmail = result!.data!.email!
                self.iGender = result!.data!.gender!.toInt()!
                self.is_disabled = result!.data!.is_disabled
                self.strLast_login_time = result!.data!.last_login_time
                self.nikename = result!.data!.nikename
                self.phone = result!.data!.phone
                self.username = result!.data!.username
                
                self.loadData = UserCenterLoadStat.LoadUserSucceed
                
                self.parseComeForm()
                
                loadDid(bLoadRet: UserCenterLoadStat.LoadUserSucceed)
                
            } else {
                
                self.loadData = UserCenterLoadStat.LoadUserError
                loadDid(bLoadRet: UserCenterLoadStat.LoadUserError)
            }
        }
    }
    
    /**
    解析地址信息
    */
    func parseComeForm() {
        
        if strComefrom == "" {
            
            return
            
        }
        
        var nstrComeform : NSString = strComefrom
        var characterSet: NSCharacterSet = NSCharacterSet(charactersInString: "-")
        
        var anySep = nstrComeform.componentsSeparatedByCharactersInSet(characterSet) as! Array<NSString>
        
        //省
        var userProvince : String = anySep[0] as String
        
        for var index = 0; index < loaclDate.count; index++ {
            var province: String? = loaclDate?.objectAtIndex(index).objectForKey("state") as! String!
            if  province == userProvince {
                userProvinceIndex = index
            }
        }
        
        if 2 == anySep.count {
            
            //城市
            var userCity : String = anySep[1] as String
            strComefrom = userProvince + "-" + userCity
            
            
            
            var cities: AnyObject? = loaclDate?.objectAtIndex(userProvinceIndex).objectForKey("cities")
            
            for var index = 0; index < cities!.count; index++ {
                
                var city: String? = cities?.objectAtIndex(index) as! String!
                
                if city == userCity {
                    userCityIndex = index
                }
            }
            
        }
        
        

    }
    
    
    /**
    更新用户信息
    */
    func updateUserInfo(updateDid : (updateRet : Bool, msg : String?) -> ()) {
        
        if nil == iGender {
            iGender = 0
        }
                
        HttpHelper<CommmonMsgRet>.updateUserInfo(nikename, birthday: strBirthday, comefrom: strComefrom, gender: "\(iGender!)") { (result) -> () in
            
            dispatch_async(dispatch_get_main_queue(),{
            
                if nil == result?.code {
                    updateDid(updateRet: false, msg : result?.msg)
                    return
                }
            
                if "1001" != result?.code! {
                    updateDid(updateRet: false, msg : result?.msg)
                    return
                }
                
                updateDid(updateRet: true, msg : result?.msg)
            })
        }
    }
    
    /**
    上传头像
    
    :param: avatarImage 头像
    :param: imageName   文件名
    :param: updateProc  更新完成回调
    */
    func updateAvatar(avatarImage : UIImage!, imageName : String!, updateProc : (result : Bool) -> ()) {
        
        //压缩图片
        var newImage = Common.imageWithImageSimple(avatarImage, newSize: avatarSize)
        
        //保存图片
        Common.saveImage(newImage, WithName: imageName)
        
        //上传图片
        var avatarUrl : NSURL = NSURL(fileURLWithPath: NSHomeDirectory().stringByAppendingPathComponent("Library/Caches") + "/\(imageName)")!
        
        HttpHelper<CommmonMsgRet>.updateAvatar(avatarUrl) { (result) -> () in
            
            if nil == result?.code {
                updateProc(result: false)
                return
            }
            
            if "1001" == result?.code {
                
                updateProc(result: true)
                
            } else {
                updateProc(result: false)
            }
        }
    }
    
    
}