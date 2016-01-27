//
//  HttpHelper.swift
//  CavyGame
//
// 封装了http请求，处理网络返回数据功能
//
//  Created by longjining on 15/7/30.
//  Copyright (c) 2015年 com.lvwenhan. All rights reserved.
//

import Foundation


public protocol ResponseConvertible{
    typealias Result
    static func convertFromData(response: HTTPResponse!) -> (Result?)
}


enum GameType : String{
    // 普通游戏，专区
    case gameList = "gamelist"
    case prefecture = "prefecture"
}

enum LogCode : Int{
    case OPENAPP = 0 // 打开app
}
// 各个接口的实际业务返回结果

/**
*  通用http返回结构 （提交意见反馈、发送验证码）
*/
struct CommmonMsgRet : ResponseConvertible{
    var code: String?
    var msg: String?
    init(_ decoder: JSONDecoder) {
        code = decoder["code"].string
        msg = decoder["msg"].string
    }
    
    typealias Result = CommmonMsgRet  // 通过别名的方式，使得闭包参数可以是任意类型的
    static func convertFromData(response: HTTPResponse!) -> (CommmonMsgRet?) {
        
        if nil == response.responseObject {
            return nil
        }
        
        var commmonMsgRet = CommmonMsgRet(JSONDecoder(response.responseObject!))
        return (commmonMsgRet)
    }
}

/**
*  版本检查更新结构
*/
struct UpdateInfo : ResponseConvertible{
    var build : String?
    var intro : String?
    var needupdate : String?
    var pagename : String?
    var url : String?
    var version : String?
   
    init(_ decoder: JSONDecoder) {
        build = decoder["build"].string
        intro = decoder["intro"].string
        needupdate = decoder["needupdate"].string
        pagename = decoder["pagename"].string
        url = decoder["url"].string
        version = decoder["version"].string
    }
    
    typealias Result = UpdateInfo  // 通过别名的方式，使得闭包参数可以是任意类型的
    static func convertFromData(response: HTTPResponse!) -> (UpdateInfo?) {
        
        if nil == response.responseObject {
            return nil
        }
        
        var sysAnnouncement = UpdateInfo(JSONDecoder(response.responseObject!))
        return (sysAnnouncement)
    }
}

/**
*  系统公告数据信息结构
*/
struct NoticeData {
    var content: String?
    var create_time: String?
    var detia_url: String?
    var msg_id:Int?
    var msgicon:String?
    var nickname:String?
    var receiver:Int?
    var sender:Int?
    var title:String?
    var type:String?
    init(_ decoder: JSONDecoder) {
        content = decoder["content"].string
        create_time = decoder["create_time"].string
        detia_url = decoder["detailUrl"].string
        msg_id = decoder["msg_id"].integer
        nickname = decoder["nickname"].string
        receiver = decoder["receiver"].integer
        sender = decoder["sender"].integer
        title = decoder["title"].string
        type = decoder["type"].string
        msgicon = decoder["msgicon"].string
    }
}

/**
*  专区信息结构
*/
struct PrefectureSubInfo {
    var bannerphone : String?     // 图片
    var intro : String?           // 介绍
    var prefectureId : Int?    // 专区id
    var style : String?           // 风格
    var title : String?           // 标题
    
    init(_ decoder: JSONDecoder) {
        
        bannerphone  = decoder["bannerphone"].string
        intro        = decoder["intro"].string
        prefectureId = decoder["prefectureId"].integer
        style        = decoder["style"].string
        title        = decoder["title"].string
    }
}

/**
*  游戏信息结构
*/
struct GameSubInfo {
    
    var downcount : String?
    var downurl : String?
    var plisturl : String?
    var filesize : String?
    var gamedesc : String?
    var gameid : String?
    var gamename : String?
    var icon : String?
    var packpagename : String?
    var version : String?
    var downStd : Int?
    var downLen : Double?
    
    init() {
        downStd      = -1
        downLen      = 0
    }
    init(_ decoder: JSONDecoder) {
        
        // 普通游戏
        downcount    = decoder["downcount"].string
        downurl      = decoder["downurl"].string
        plisturl      = decoder["plistUrl"].string
        filesize     = decoder["filesize"].string
        gamedesc     = decoder["gamedesc"].string
        gameid       = decoder["gameid"].string
        gamename     = decoder["gamename"].string
        icon         = decoder["icon"].string
        packpagename = decoder["packpagename"].string
        version      = decoder["version"].string
        downStd      = -1
        downLen      = 0
    }
}

struct GameInfo {
    var gameType : String?
    var gameSubInfo : GameSubInfo!
    var prefectureSubInfo : PrefectureSubInfo!
    
    init(_ decoder: JSONDecoder) {
        
        gameType = decoder["type"].string

        let typeTmp = GameType.prefecture.rawValue

        if gameType == typeTmp{
            // 专区游戏
            prefectureSubInfo = PrefectureSubInfo(decoder)
        }else{
            // gameType == GameType.gameList.rawValue
            // 普通游戏
            gameSubInfo = GameSubInfo(decoder)
        }
    }
}

/**
*  推荐的固定2个游戏信息结构
*/
struct GameLitterInfo {
    var style : String?
    var gameid : String?
    var images : String?
    var name : String?
    var type : String?  // prefecture
    
    init(_ decoder: JSONDecoder) {
        
        style = decoder["style"].string
        gameid = decoder["gameid"].string
        images = decoder["images"].string
        name = decoder["name"].string
        type = decoder["type"].string
    }
}

struct BannerInfo {
    var gameid : String?
    var image : String?
    var style : String?
    var type : String?
    var title : String?
    var url : String?
    
    init(_ decoder: JSONDecoder) {
        gameid = decoder["gameid"].string
        image = decoder["bannerphone"].string
        style = decoder["style"].string
        type = decoder["type"].string
        url = decoder["url"].string
        title = decoder["title"].string
        
    }
}

/**
*  推荐游戏信息结构
*/
struct GameListInfo : ResponseConvertible{
    var code : String?
    var pageNum : Int?
    
    var banners = [BannerInfo]()
    var recomd2Game = [GameLitterInfo]()
    var gameList = [GameInfo]()
    
    init() {
    }
    
    init(_ decoder: JSONDecoder){
        
        code = decoder["code"].string
        
        let data = decoder["data"]
        pageNum = data["pagenum"].string?.toInt()
       
       // banner
        if let bannerInfo = data["banner"].array {
            
            for bannerphone in bannerInfo{
                self.banners.append(BannerInfo(bannerphone))
            }
        }

        // 2games
        recomd2Game.append(GameLitterInfo(data["game1"]))
        recomd2Game.append(GameLitterInfo(data["game2"]))

        if let gamelist = data["gamelist"].array {
            
            for gameInfo in gamelist{
                gameList.append(GameInfo(gameInfo))
            }
         }
    }
    
    typealias Result = GameListInfo  // 通过别名的方式，使得闭包参数可以是任意类型的
    static func convertFromData(response: HTTPResponse!) -> (GameListInfo?) {
        
        if (nil == response.responseObject) {
            return nil
        }
        
        var sysAnnouncement = GameListInfo(JSONDecoder(response.responseObject!))
        return (sysAnnouncement)
    }
}

/**
*  分类游戏信息结构
*/
struct ClassificationSunInfo {
    var classid : String?
    var classname : String?
    var gameList = [GameInfo]()
    
    init(_ decoder: JSONDecoder) {
        classid = decoder["classid"].string
        classname = decoder["classname"].string
        
        // gamelist
        if let gamelist = decoder["gamelist"].array {
            
            for gameInfo in gamelist{
                gameList.append(GameInfo(gameInfo))
            }
        }
    }
}

struct ClassificationInfo : ResponseConvertible {
    var code : String?
    var classListSubInfo = [ClassificationSunInfo]()
    
    init() {
    }
    init(_ decoder : JSONDecoder) {
        code = decoder["code"].string

        if let classList = decoder["data"].array {
            
           // println(decoder.print())
            for classInfo in classList{
               classListSubInfo.append(ClassificationSunInfo(classInfo["classification"]))
            }
        }
    }
    
    typealias Result = ClassificationInfo  // 通过别名的方式，使得闭包参数可以是任意类型的
    static func convertFromData(response: HTTPResponse!) -> (ClassificationInfo?) {
        
        if nil == response.responseObject {
            return nil
        }
        
        var sysAnnouncement = ClassificationInfo(JSONDecoder(response.responseObject!))
        return (sysAnnouncement)
    }
}

/**
*  系统公告结构
*/
struct SysAnnouncement : ResponseConvertible{
    var code : String?
    var msg : String?
    var data : Array<NoticeData>?
    init() {
    }
    init(_ decoder : JSONDecoder) {
        code = decoder["code"].string
        msg = decoder["msg"].string
        if let letAddrs = decoder["data"].array {
            data = Array<NoticeData>()
            for dateDecoder in letAddrs {
                data?.append(NoticeData(dateDecoder))
            }
        }
    }
    
    typealias Result = SysAnnouncement  // 通过别名的方式，使得闭包参数可以是任意类型的
    static func convertFromData(response: HTTPResponse!) -> (SysAnnouncement?) {
        
        if nil == response.responseObject {
            return nil
        }
        
        var sysAnnouncement = SysAnnouncement(JSONDecoder(response.responseObject!))
        return (sysAnnouncement)
    }
}

/**
*  用户信息
*/
struct UserData {
    var avatar : String?
    var birthday : String?
    var email : String?
    var gender : String?
    var is_disabled : Bool?
    var last_login_time : String?
    var nikename : String?
    var phone : String?
    var userid : Int?
    var username : String?
    var usertoken : String?
    
    init(_ decoder : JSONDecoder) {
        avatar = decoder["avatar"].string
        birthday = decoder["birthday"].string
        email = decoder["email"].string
        gender = decoder["gender"].string
        is_disabled = decoder["is_disabled"].bool
        last_login_time = decoder["last_login_time"].string
        nikename = decoder["nikename"].string
        phone = decoder["phone"].string
        userid = decoder["userid"].integer
        username = decoder["username"].string
        usertoken = decoder["usertoken"].string
    }
}

/**
*  用户登录
*/
struct UserLoginMsg :ResponseConvertible{
    var code : String?
    var msg : String?
    var data : UserData?
    init(_ decoder : JSONDecoder) {
        code = decoder["code"].string
        msg = decoder["msg"].string
        data = UserData(decoder["data"])
    }
    
    typealias Result = UserLoginMsg  // 通过别名的方式，使得闭包参数可以是任意类型的
    static func convertFromData(response: HTTPResponse!) -> (UserLoginMsg?) {
        
        if nil == response.responseObject {
            return nil
        }
        
        var userLogin = UserLoginMsg(JSONDecoder(response.responseObject!))
        return (userLogin)
    }
}

/**
*  用户中心 -- 用户信息
*/
struct UserCenterUserInfo {
    var avatar : String!
    var birthday : String!
    var comefrom : String!
    var email : String!
    var gender : String!
    var is_disabled : Bool!
    var last_login_time : String!
    var nikename : String!
    var phone : String!
    var username : String!
    
    init(_ decoder : JSONDecoder) {
        avatar = decoder["avatar"].string
        birthday = decoder["birthday"].string
        comefrom = decoder["comefrom"].string
        email = decoder["email"].string
        gender = decoder["gender"].string
        is_disabled = decoder["is_disabled"].bool
        last_login_time = decoder["last_login_time"].string
        nikename = decoder["nikename"].string
        phone = decoder["phone"].string
        username = decoder["username"].string
    }
}

/**
*  用户中心 -- 用户信息请求返回消息结构
*/
struct UserCenterInfoMsg :ResponseConvertible{
    var code : String?
    var msg : String?
    var data : UserCenterUserInfo?
    init(_ decoder : JSONDecoder) {
        code = decoder["code"].string
        msg = decoder["msg"].string
        data = UserCenterUserInfo(decoder["data"])
    }
    
    typealias Result = UserCenterInfoMsg  // 通过别名的方式，使得闭包参数可以是任意类型的
    static func convertFromData(response: HTTPResponse!) -> (UserCenterInfoMsg?) {
        
        if nil == response.responseObject {
            return nil
        }
        
        var userLogin = UserCenterInfoMsg(JSONDecoder(response.responseObject!))
        return (userLogin)
    }
}

/**
*  更新用户信息结构
*/
struct UserCenterUpdateInfo {
    var nikename : String!
    var birthday : String!
    var comefrom : String!
    var gender : String!
    
    init(){
        nikename = ""
        birthday = ""
        comefrom = ""
        gender = "1"
    }
}

struct HotKey {
    var hotkey : Array<String>?
    
    init(_ decoder: JSONDecoder) {
        if let hotkeyArray = decoder["hotkey"].array {
            hotkey = Array<String>()
            for hotkeyDecoder in hotkeyArray {
                hotkey?.append(hotkeyDecoder.string!)
            }
        }
    }
}

/**
*  热门搜索
*/
struct HotKeyRet :ResponseConvertible{
    var code : String?
    var data : HotKey?
    var msg : String?
    
    init(_ decoder: JSONDecoder) {
        
        code = decoder["code"].string
        msg = decoder["msg"].string
        data = HotKey(decoder["data"])
        
    }
    
    typealias Result = HotKeyRet  // 通过别名的方式，使得闭包参数可以是任意类型的
    static func convertFromData(response: HTTPResponse!) -> (HotKeyRet?) {
        
        if nil == response.responseObject {
            return nil
        }
        
        var userLogin = HotKeyRet(JSONDecoder(response.responseObject!))
        return (userLogin)
    }
}

/**
*  搜索游戏--游戏列表
*/
struct SearchGameList {
    var gameList : Array<GameInfo> = Array<GameInfo>()
    
    init(_ decoder: JSONDecoder) {
        
        if let gameListArray = decoder["gamelist"].array {
            for gameDecoder in gameListArray {
                gameList.append(GameInfo(gameDecoder))
            }
        }
    }
}

/**
*  搜索游戏结果
*/
struct SearchGameRet  :ResponseConvertible{
    var code : String?
    var data : SearchGameList?
    var msg : String?
    
    init(_ decoder: JSONDecoder) {
        
        code = decoder["code"].string
        msg = decoder["msg"].string
        data = SearchGameList(decoder["data"])
        
    }
    
    typealias Result = SearchGameRet  // 通过别名的方式，使得闭包参数可以是任意类型的
    static func convertFromData(response: HTTPResponse!) -> (SearchGameRet?) {
        
        if nil == response.responseObject {
            return nil
        }
        
        var searchRet = SearchGameRet(JSONDecoder(response.responseObject!))
        return (searchRet)
    }
}

/**
*  游戏图片结构
*/
struct GameViewimage {
    var bigimage : String?
    var smallimage : String?
    
    init(_ decoder: JSONDecoder) {
        
        bigimage = decoder["bigimage"].string
        smallimage = decoder["smallimage"].string
    }
}

/**
*  游戏信息数据
*/
struct GameDetailsInfoData {
    var developers : String?
    var downcount : String?
    var downurl : String?
    var plisturl : String?
    var filesize : String?
    var gamedesc : String?
    var gamedetial : String?
    var gameid : String?
    var gamename : String?
    var gametype : String?
    var icon : String?
    var pageName : String?
    var shareUrl : String?
    var updateTime : String?
    var verimage : Array<GameViewimage> = Array<GameViewimage>()
    var version : String?
    var viewVersion : String?
    var viewimage : Array<GameViewimage> = Array<GameViewimage>()
    var situation : String?
    
    init() {
        
    }
    
    init(_ decoder: JSONDecoder) {
        
        developers = decoder["developers"].string
        downcount = decoder["downcount"].string
        downurl = decoder["downurl"].string
        plisturl = decoder["plistUrl"].string
        filesize = decoder["filesize"].string
        gamedesc = decoder["gamedesc"].string
        gamedetial = decoder["gamedetial"].string
        gameid = decoder["gameid"].string
        plisturl = decoder["plistUrl"].string
        gamename = decoder["gamename"].string
        gametype = decoder["gametype"].string
        icon = decoder["icon"].string
        pageName = decoder["pageName"].string
        shareUrl = decoder["shareUrl"].string
        updateTime = decoder["updateTime"].string
        version = decoder["version"].string
        viewVersion = decoder["viewVersion"].string
        situation = decoder["situation"].string
        
        if let imageArray = decoder["verimage"].array {
            for imageDecoder in imageArray {
                verimage.append(GameViewimage(imageDecoder))
            }
        }
        
        if let imageArray = decoder["viewimage"].array {
            for imageDecoder in imageArray {
                viewimage.append(GameViewimage(imageDecoder))
            }
        }
        
    }
}

/**
*  游戏详情返回结构
*/
struct GameDetailsInfo: ResponseConvertible {
    var code : String?
    var data : GameDetailsInfoData?
    var msg : String?
    
    init(_ decoder: JSONDecoder) {
        
        code = decoder["code"].string
        msg = decoder["msg"].string
        data = GameDetailsInfoData(decoder["data"])

    }
    
    typealias Result = GameDetailsInfo  // 通过别名的方式，使得闭包参数可以是任意类型的
    static func convertFromData(response: HTTPResponse!) -> (GameDetailsInfo?) {
        
        if nil == response.responseObject {
            return nil
        }
        
        var gameDetails = GameDetailsInfo(JSONDecoder(response.responseObject!))
        return (gameDetails)
    }
}

/**
*  评论数据
*/
struct ReViewInfoData {
    var avatar: String?
    var com_content: String?
    var com_datetime: String?
    var nickname: String?
    var userId: String?
    
    init(_ decoder: JSONDecoder) {
        avatar = decoder["avatar"].string
        com_content = decoder["com_content"].string
        com_datetime = decoder["com_datetime"].string
        nickname = decoder["nickname"].string
        userId = decoder["userId"].string
    }
    
    init() {
        
    }
}

/**
*  评论结果
*/
struct ReViewInfoRet : ResponseConvertible {
    var code : String?
    var data : Array<ReViewInfoData>?
    var msg : String?
    var pageNum : Int?
    
    init(_ decoder: JSONDecoder) {
        
        code = decoder["code"].string
        msg = decoder["msg"].string
        pageNum = decoder["pagenum"].string?.toInt()
        
        if let dataArray = decoder["data"].array {
            data = Array<ReViewInfoData>()
            for dataDecoder in dataArray {
                data!.append(ReViewInfoData(dataDecoder))
            }
        }
    }
    
    typealias Result = ReViewInfoRet  // 通过别名的方式，使得闭包参数可以是任意类型的
    static func convertFromData(response: HTTPResponse!) -> (ReViewInfoRet?) {
        
        if nil == response.responseObject {
            return nil
        }
        
        var gameDetails = ReViewInfoRet(JSONDecoder(response.responseObject!))
        return (gameDetails)
    }
}

/**
*  游戏专区列表
*/
struct PreList {
    var bannerphone : String?
    var intro : String?
    var prefectureId : Int?
    var style : String?
    var title : String?
    var type : String?
    
    init(_ decoder: JSONDecoder) {
        
        bannerphone = decoder["bannerphone"].string
        intro = decoder["intro"].string
        prefectureId = decoder["prefectureId"].integer
        style = decoder["style"].string
        title = decoder["title"].string
        type = decoder["type"].string
        
    }
    
    init() {
        
    }
}

/**
*  游戏专区数据
*/
struct PrefectureData {
    
    var preList : Array<PreList>?
    
    init(_ decoder: JSONDecoder) {
        
        if let dataArray = decoder["preList"].array {
            preList = Array<PreList>()
            for dataDecoder in dataArray {
                preList!.append(PreList(dataDecoder))
            }
        }
    }
    
}

/**
*  游戏专区信息
*/
struct PrefectureInfoRet : ResponseConvertible {
    var code : String?
    var data : PrefectureData?
    var msg : String?
    
    init(_ decoder: JSONDecoder) {
        
        code = decoder["code"].string
        msg = decoder["msg"].string
        data = PrefectureData(decoder["data"])

    }
    
    typealias Result = PrefectureInfoRet  // 通过别名的方式，使得闭包参数可以是任意类型的
    static func convertFromData(response: HTTPResponse!) -> (PrefectureInfoRet?) {
        
        if nil == response.responseObject {
            return nil
        }
        
        var prefectureInfo = PrefectureInfoRet(JSONDecoder(response.responseObject!))
        return (prefectureInfo)
    }
}

/**
*  专区列表数据
*/
struct PrefectureListData {
    var bannerphone : String?
    var gamelist : Array<GameSubInfo> = Array<GameSubInfo>()
    var intro : String?
    var style : String?
    var title : String?
    var pageNum : Int?
    
    init() {
        
    }
    
    init(_ decoder: JSONDecoder) {
        
        bannerphone = decoder["bannerphone"].string
        intro = decoder["intro"].string
        style = decoder["style"].string
        title = decoder["title"].string
        pageNum = decoder["pagenum"].string?.toInt()
        
        if let dataArray = decoder["gamelist"].array {
            for dataDecoder in dataArray {
                gamelist.append(GameSubInfo(dataDecoder))
            }
        }
        
    }
    
}

/**
*  专区列表返回结果
*/
struct PrefectureListRet : ResponseConvertible {
    var code : String?
    var data : PrefectureListData?
    var msg : String?
    
    init(_ decoder: JSONDecoder) {
        
        code = decoder["code"].string
        msg = decoder["msg"].string
        data = PrefectureListData(decoder["data"])
        
    }
    
    typealias Result = PrefectureListRet  // 通过别名的方式，使得闭包参数可以是任意类型的
    static func convertFromData(response: HTTPResponse!) -> (PrefectureListRet?) {
        
        if nil == response.responseObject {
            return nil
        }
        
        var prefectureInfo = PrefectureListRet(JSONDecoder(response.responseObject!))
        return (prefectureInfo)
    }
}

/**
* 排行名称列表
*/
struct RankList {
    var rankname: String?
    var ranktype: String?
    
    init(_ decoder: JSONDecoder) {
        rankname = decoder["rankname"].string
        ranktype = decoder["ranktype"].string
    }
}

/**
*  类别标签
*/
struct ClassTag {
    var tagId : Int?
    var tagName : String?
    var tagImgUrl : String?
    var tagTextColor : String?
    
    init(_ decoder: JSONDecoder) {
        
        tagId = decoder["mark_id"].integer
        tagName = decoder["mark_name"].string
        tagImgUrl = decoder["mark_imgurl"].string
        tagTextColor = decoder["mark_color"].string
    }
}

/**
*  classification
*/
struct Classification {
    
    var class_id : Int?
    var class_name : String?
    var class_imgurl : String?
    var tagArray : Array<ClassTag> = Array<ClassTag>()
    
    init(_ decoder: JSONDecoder) {
        
        class_id = decoder["class_id"].integer
        class_name = decoder["class_name"].string
        class_imgurl = decoder["class_imgurl"].string
        
        for tagData in decoder["markarr"].array! {
            
            tagArray.append(ClassTag(tagData))
            
        }
        
    }
    
}

/**
*  分类
*/
struct ClassificationMsg: ResponseConvertible {
    var code: String?
    var data: Array<Classification> = Array<Classification>()
    var msg: String?
    
    init(_ decoder: JSONDecoder) {
        code = decoder["code"].string
        msg = decoder["msg"].string
        data = Array<Classification>()
        for classData in decoder["data"].array! {
            
            data.append(Classification(classData))
            
        }
    }
    
    typealias Result = ClassificationMsg
    static func convertFromData(response: HTTPResponse!) -> (Result?) {
        
        if response.responseObject == nil {
            return nil
        }
        
        return ClassificationMsg(JSONDecoder(response.responseObject!))
        
    }
}

/**
>>>>>>> develop
*  排行名称列表结构
*/

struct RankListInfo : ResponseConvertible {
    var code : String?
    var data : Array<RankList>?
    var msg : String?
    
    init(){
    
    }
    init(_ decoder : JSONDecoder) {
        code = decoder["code"].string
        msg = decoder["msg"].string
        
        if let ranklists = decoder["data"].array {
            data = Array<RankList>()
            for dateDecoder in ranklists {
            data?.append(RankList(dateDecoder))
            }
        }
    }
    typealias Result = RankListInfo
    static func convertFromData(response: HTTPResponse!) -> (RankListInfo?) {
        
        if response.error != nil {
            return nil
        }
        
        if nil == response.responseObject {
            return nil
        }
        var rankListNameArray = RankListInfo(JSONDecoder(response.responseObject!))
        return (rankListNameArray)
        
    }
    
}

#if DEBUG
    let serverAddr = "http://115.28.144.243/gamecenter/"
#else
    let serverAddr = "https://game.tunshu.com/"
#endif

public class HttpHelper< T:ResponseConvertible>{

    
    // 共用的http get请求
    static public func reqGet(url: String, parameters: Dictionary<String,AnyObject>?, completionHandlerRet:(T.Result?)->()){
        
        var parametersTmp: Dictionary<String,AnyObject> = Dictionary()
        
        if nil != parameters {
            parametersTmp = parameters!
        }
        
        parametersTmp["phonetype"] = "\(Common.phonetype)"
        parametersTmp["userid"] = "\(Common.userID())"
        parametersTmp["token"] = "\(Common.userInfo.usertoken!)"
        parametersTmp["language"] = "\(Common.getPreferredLanguage())"
        
//        var strPara = url
//        for (key, name) in parametersTmp {
//            
//            if strPara != url {
//                
//                strPara = strPara + "&"
//            }
//            
//            strPara = strPara + "\(key)=\(name)"
//        }
        
       //println("reqGet : \(strPara)")
        
        let request = HTTPTask()
        request.GET(url,
            parameters : parametersTmp,
            completionHandler: {(response: HTTPResponse)  in
                
                let object = T.convertFromData(response)
                
                completionHandlerRet(object)
        })
    }
    
    /**
    post
    
    :param: url                  url
    :param: parameters           HTTP请求参数
    :param: completionHandlerRet 完成回调
    */
    static public func reqPost(url: String, parameters: Dictionary<String,AnyObject>?, completionHandlerRet:(T.Result?)->()){
        
        var parametersTmp: Dictionary<String,AnyObject> = Dictionary()
        
        if nil != parameters {
            parametersTmp = parameters!
        }
        
        parametersTmp["phonetype"] = "\(Common.phonetype)"
        parametersTmp["userid"] = "\(Common.userID())"
        parametersTmp["token"] = "\(Common.userInfo.usertoken!)"
        parametersTmp["language"] = "\(Common.getPreferredLanguage())"
        
        
        let request = HTTPTask()
        
        request.POST(url, parameters: parametersTmp,
            completionHandler: {(response: HTTPResponse)  in
                
                let object = T.convertFromData(response)
                
                completionHandlerRet(object)
        })
        
    }
    
    
    /**
    意见反馈
    
    :param: feedbackText         反馈意见
    :param: contactText          联系方式
    :param: completionHandlerRet 结果处理
    
    web接口:http://cavytest.tunshu.com/common/index?ac=useropinion&userid=-1&content=aaaa&contact=18795890711
    
    */
    static public func feedback(feedbackText : String, var contactText : String, completionHandlerRet:(T.Result?)->()){
        
        let url = serverAddr + "common/index?"
        
        let parameters: Dictionary<String,AnyObject> = ["ac":"useropinion",
        "contact":"\(contactText)",
        "content":"\(feedbackText)", ];
        
        reqPost(url, parameters: parameters, completionHandlerRet: completionHandlerRet)
    }
    
    /**
    获取系统公告信息
    
    :param: completionHandlerRet 结果处理
    
    web接口:http://cavytest.tunshu.com/common/index?ac=sysmessage&pagesize=5&pagenum=1&userid=-1
    
    */
    static public func getNoticeInfo(pagenum : Int, pagesize : Int, completionHandlerRet:(T.Result?)->()) {
        
        let url = serverAddr + "common/index?"
        
        let parameters: Dictionary<String,AnyObject> = ["ac":"sysmessage",
        "pagesize":"\(pagesize)",
        "pagenum":"\(pagenum)",];
        
        reqGet(url, parameters: parameters, completionHandlerRet: completionHandlerRet)
    }
    
    /**
    用户登录
    
    :param: userName             用户名
    :param: userPassword         密码
    :param: completionHandlerRet 结果处理
    
    web接口:http://cavytest.tunshu.com/authority/index?ac=login&password=1&username=1
    
    */
    static public func loginUser(userName:String!, userPassword:String!, completionHandlerRet:(T.Result?)->()) {
        
        let url = serverAddr + "authority/index?"
        
        let parameters: Dictionary<String, AnyObject> = ["ac":"login",
        "password":"\(userPassword)",
        "username":"\(userName)",]
        
        reqGet(url, parameters: parameters, completionHandlerRet: completionHandlerRet)
    }
    
    
    /**
    发送手机验证码
    
    :param: phoneNum             手机号码
    :param: completionHandlerRet 结果处理
    
    web接口:http://cavytest.tunshu.com/authority/index?ac=certification&phone=18795890681
    */
    static public func sendPhoneCode(phoneNum :String, forgetpwd : Bool, completionHandlerRet:(T.Result?)->()) {
        
        let url = serverAddr + "authority/index?"


        var parameters: Dictionary<String, AnyObject> = ["ac":"certification",
            "phone":"\(phoneNum)",]
        
        if forgetpwd {
            
            parameters["forgetpwd"] = ""
            
        }
        
        reqGet(url, parameters: parameters, completionHandlerRet: completionHandlerRet)
    }
    
    /**
    注册请求
    
    :param: phoneNum             手机号
    :param: passwd               密码
    :param: authCode             验证码
    :param: completionHandlerRet 结果处理
    
    web接口:http://cavytest.tunshu.com/authority/index?ac=userregist&username=17722618599&password=111111&regtype=0&code=6721
    */
    static public func registerUser(userName :String, regtype : Int, passwd :String, authCode :String, completionHandlerRet:(T.Result?)->()) {
        
        let url = serverAddr + "authority/index?"
        
        let parameters: Dictionary<String, AnyObject> = ["ac":"userregist",
            "username":"\(userName)",
            "password":"\(passwd)",
            "regtype":"\(regtype)",
            "code":"\(authCode)",]
        
        reqGet(url, parameters: parameters, completionHandlerRet: completionHandlerRet)
    }
    
    /**
    获取推荐游戏信息请求
    
    :param: nil
    
    web接口:http://cavytest.tunshu.com/mobileIndex/index?ac=recommend&phonetype=IOS&userid=-1&token=1&language=zh
    */
    static public func getRecommendatonList(completionHandlerRet:(T.Result?)->()) {
        
      //  let url = serverAddr + "CavyGameCenter/mobilegame/index?"
        let url = serverAddr + "mobileIndex/index?"
        
        let parameters: Dictionary<String, AnyObject> = ["ac":"recommend",]
        
        reqGet(url, parameters: parameters, completionHandlerRet: completionHandlerRet)
    }
    
    /**
    获取游戏排行榜列表
    
    - parameter completionHandlerRet: 结果处理
    web接口(get):http://game.tunshu.com/mobileIndex/index?ac=newranking
    */

    static public func getRankingListName(completionHandlerRet:(T.Result?)->()) {
        
        let url = serverAddr + "mobileIndex/index?"

        let parameters: Dictionary<String, AnyObject> = ["ac":"newranking"];
        
        reqGet(url, parameters: parameters, completionHandlerRet: completionHandlerRet)
    }
    
    /**
    通过 ranktype 来显示排行榜信息
    
    - parameter pagenum:              需要获取的页数据
    - parameter ranktype:             排行榜种类
    - parameter pagesize:             获取每一条数据
    - parameter completionHandlerRet: 结果处理
    web接口(POST)：http://cavytest.tunshu.com/mobileIndex/index?ac=getrankgame&ranktype=newup&pagenum=1&pagesize=5
    
    */
    static public func getRankingList(pagenum : Int, ranktype : String, pagesize : Int, completionHandlerRet:(T.Result?)->()) {
        
        let url = serverAddr + "appIndex/index?"
        
        let parameters: Dictionary<String, AnyObject> = ["ac":"getrankgames",
            "ranktype":"\(ranktype)",
            "pagenum":"\(pagenum)",
            "pagesize":"\(pagesize)",]
        
        reqGet(url, parameters: parameters, completionHandlerRet: completionHandlerRet)
    }
    
    /**
    获取游戏排行信息请求
    
    :param: pagenum              需要获取的页数据
    :param: pagesize             获取一页的条数
    :param: completionHandlerRet 结果处理
    web接口:http://cavytest.tunshu.com/mobileIndex/index?ac=ranking&pagenum=1&pagesize=5
    */
    static public func getRankList(pagenum : Int, pagesize : Int, completionHandlerRet:(T.Result?)->()) {
        
        let url = serverAddr + "mobileIndex/index?"
        
        let parameters: Dictionary<String, AnyObject> = ["ac":"ranking",
            "pagenum":"\(pagenum)",
            "pagesize":"\(pagesize)",]
        
      
        reqGet(url, parameters: parameters, completionHandlerRet: completionHandlerRet)
    }
    
    /**
    获取用户信息
    
    :param: completionHandlerRet 结果处理
    
    web接口：http://cavytest.tunshu.com/usercenter?ac=useronedata&userid=513&token= 5aafa9bb-b54d-4eab-a419-7f53732685ec&phonetype=ios&language=zh
    
    */
    static public func getUserInfo(completionHandlerRet:(T.Result?)->()) {
        
        let url = serverAddr + "usercenter?"
        
        let preferredLanguage = Common.getPreferredLanguage()

        let parameters: Dictionary<String, AnyObject> = ["ac":"useronedata",]
        
        reqGet(url, parameters: parameters, completionHandlerRet: completionHandlerRet)
    }
    
    /**
    更新用户数据
    
    :param: nikename             <#nikename description#>
    :param: birthday             <#birthday description#>
    :param: comefrom             <#comefrom description#>
    :param: gender               <#gender description#>
    :param: completionHandlerRet <#completionHandlerRet description#>
    
    web 接口：http://cavytest.tunshu.com/usercenter?ac=updateuserdata&userid=513&token=5aafa9bb-b54d-4eab-a419-7f53732685ec&phonetype=ios&language=zh&nikename=aaa&birthday=1999-09-09&comefrom=河北省-保定市&gender=1
    */
    static public func updateUserInfo(nikename : String!, birthday : String!, comefrom : String!, gender : String!, completionHandlerRet:(T.Result?)->()) {
        
        let url = serverAddr + "usercenter?"
        
        let preferredLanguage = Common.getPreferredLanguage()
        
        let parameters: Dictionary<String, AnyObject> = ["ac":"updateuserdata",
            "nikename":nikename,
            "birthday":birthday,
            "comefrom":comefrom,
            "gender":gender]
        
        reqGet(url, parameters: parameters, completionHandlerRet: completionHandlerRet)
        
    }
    
    /**
    HTTP 更新用户头像
    
    :param: avatarUrl            用户头像的url
    :param: completionHandlerRet 
    */
    static public func updateAvatar(avatarUrl : NSURL!, completionHandlerRet:(T.Result?)->()) {
        
        let url = serverAddr + "usercenter/updateUserImg?"
        
        let parameters = ["userid" : "\(Common.userInfo.userid!)",
            "imgFile" : HTTPUpload(fileUrl: avatarUrl)]
        
        
        reqPost(url, parameters: parameters, completionHandlerRet: completionHandlerRet)
        
    }
    
    /**
    获取分类信息
    
    :param: nil
    :param: completionHandlerRet
    */
    static public func getClassInfo(completionHandlerRet:(T.Result?)->()) {
        
        let url = serverAddr + "mobileIndex/index?"
        
        let parameters: Dictionary<String, AnyObject> = ["ac":"classification",]
        
        reqGet(url, parameters: parameters, completionHandlerRet: completionHandlerRet)
    }
    
    /**
    热门搜索
    
    :param: completionHandlerRet
    
    web 接口：http://cavytest.tunshu.com/appIndex/index?ac=hotkeyword&pagenum=1&pagesize=5
    */
    static public func getHotKey(completionHandlerRet:(T.Result?)->()) {
        
        let url = serverAddr + "appIndex/index?"
        
        var parameters = ["ac" : "hotkeyword",
            "pagenum" : "1",
            "pagesize" : "5"]
        
        reqGet(url, parameters: parameters, completionHandlerRet: completionHandlerRet)
    }
    
    
    /**
    搜索游戏
    
    :param: gameName             游戏名
    :param: completionHandlerRet
    */
    static public func searchGame(gameName : String, completionHandlerRet:(T.Result?)->()) {
        
        let url = serverAddr + "mobileIndex/index?"
        
        var parameters = ["ac" : "gamesearch",
            "pagenum" : "1",
            "pagesize" : "5",
            "gamekeyword" : "\(gameName)"]
        
        reqGet(url, parameters: parameters, completionHandlerRet: completionHandlerRet)
    }
    
    /**
    获取游戏详情
    
    :param: gameId               游戏ID
    :param: completionHandlerRet 回调处理
    
    web 接口:http://cavytest.tunshu.com/appIndex/index?ac=getgameview&gameid=3e5cc01d401db2d73a46f52c3b3629d0
    
    */
    static public func getGameDetailsInfo(gameId : String!, completionHandlerRet:(T.Result?)->()) {
        
        let url = serverAddr + "appIndex/index?"
        
        var parameters = ["ac" : "getgameview",
            "gameid" : "\(gameId)"]
        
        reqGet(url, parameters: parameters, completionHandlerRet: completionHandlerRet)
    }
    

    /**
    获取评论信息
    
    :param: gameId               游戏ID
    :param: pagenum              页码
    :param: pagesize             每页显示数
    :param: completionHandlerRet 回调
    
    web 接口:http://cavytest.tunshu.com/common/index?ac=getcomment&gameid=53db8a719ab9cbcfba02a73075ac5850&pagenum=1&pagesize=5
    */
    static public func getReViewInfo(gameId : String!, pagenum : Int!, pagesize : Int!, completionHandlerRet:(T.Result?)->()) {
        
        let url = serverAddr + "common/index?"
        
        var parameters = ["ac" : "getcomment",
            "pagenum" : "\(pagenum)",
            "pagesize" : "\(pagesize)",
            "gameid" : "\(gameId)"]
        
        reqGet(url, parameters: parameters, completionHandlerRet: completionHandlerRet)
    }
    
    /**
    获取游戏特定类别的游戏列表请求
    
    :param: nil
    
    web接口:http://cavytest.tunshu.com/appIndex/index?ac=getclassificationmore&classid=3&pagenum=1&pagesize=5
    */
    static public func getClassAllItemList(gameClassID : String!, pagenum : Int, pagesize : Int,completionHandlerRet:(T.Result?)->()) {
        
        let url = serverAddr + "appIndex/index?"
        
        let parameters: Dictionary<String, AnyObject> = ["ac":"getmarkgames",
            "mark_id":"\(gameClassID)",
            "pagenum":"\(pagenum)",
            "pagesize":"\(pagesize)"]
        
        reqGet(url, parameters: parameters, completionHandlerRet: completionHandlerRet)
    }
    
    /**
    提交评论
    
    :param: gameId               游戏id
    :param: content              评论
    :param: completionHandlerRet 回调
    */
    static public func sendComment(gameId : String!, content : String!, completionHandlerRet:(T.Result?)->()) {
        
        let url = serverAddr + "common/index?"
        
        let parameters: Dictionary<String, AnyObject> = ["ac":"gamecomment",
        "gameid":"\(gameId)",
        "com_content":"\(content)"]
        
        reqGet(url, parameters: parameters, completionHandlerRet: completionHandlerRet)
    }
    
    /**
    获取最新版本信息
    
    :param: completionHandlerRet 回调
    */
    static public func getVersionInfo(completionHandlerRet:(T.Result?)->()) {
        
        let url = serverAddr + "common/index?ac=cavySystemManage"
        
        reqGet(url, parameters: nil, completionHandlerRet: completionHandlerRet)
    }
    
    /**
    记录日志到服务器
    
    logCode : String  消息编码
    msg     : String  消息
    lbs     : String  位置信息
    :param: completionHandlerRet 回调
    */
    static public func logToServer(code : Int, msg : String!, lbs : String!, completionHandlerRet:(T.Result?)->()) {
        
        let url = serverAddr + "common/index?"
        
        var identifier = UIDevice.currentDevice().identifierForVendor.UUIDString
        //var name : String  = platform()
        
        //iPad,iPadAir2,iOS9.1
        var curDevice = UIDevice.currentDevice().localizedModel;
        var sysVer = UIDevice.currentDevice().systemVersion;
        var deviceMachineIDs = UIDevice.deviceModelDataForMachineIDs();
        
        
        var deviceInfo = "\(curDevice), \(deviceMachineIDs), \(sysVer)"

        var strCode = String(code)
        let parameters: Dictionary<String, AnyObject> = ["ac":"onlineFailureLog",
            "serial":"\(identifier)",
            "devinfo":"\(deviceInfo)",
            "errorcode":"\(strCode)",
            "errormsg":"\(msg)",
            "bandinfo":"",
            "LBS":"\(lbs)"]
        
        reqGet(url, parameters: parameters, completionHandlerRet: completionHandlerRet)
    }
    
    /**
    忘记密码验证码校验
    
    :param: phone                手机号码
    :param: code                 验证码
    :param: completionHandlerRet 回调
    
    web接口:http://cavytest.tunshu.com/authority/index?ac=forgetphonecheck&phone=18797686566&code=6721
    
    */
    static public func foundpwdCodeCheck(phone : String, code : String, completionHandlerRet:(T.Result?)->()){
        
        let url = serverAddr + "authority/index?"
        
        let parameters: Dictionary<String, AnyObject> = ["ac":"forgetphonecheck",
            "phone":"\(phone)",
            "code":"\(code)"]
        
        reqGet(url, parameters: parameters, completionHandlerRet: completionHandlerRet)
        
    }
    
    /**
    手机号码修改密码
    
    :param: phone                手机
    :param: pwd                  密码
    :param: completionHandlerRet 回调
    
    web 接口：http://cavytest.tunshu.com/authority/index?ac=forgetupdatepwd&phone=18797686566&password=123
    */
    static public func phoneModifyPwd(phone : String, pwd : String, completionHandlerRet:(T.Result?)->()) {
        let url = serverAddr + "authority/index?"
        
        let parameters: Dictionary<String, AnyObject> = ["ac":"forgetupdatepwd",
            "phone":"\(phone)",
            "password":"\(pwd)"]
        
        reqGet(url, parameters: parameters, completionHandlerRet: completionHandlerRet)
    }
    
    /**
    修改邮箱账号密码
    
    :param: email                邮箱
    :param: pwd                  密码
    :param: code                 验证码
    :param: completionHandlerRet 回调
    
    web 接口：http://cavytest.tunshu.com/authority/index?ac=forgetpwdImgCheck&imgcheckcode=vx9a&email=812424136@qq.com
    */
    static public func emailModifyPwd(email : String, pwd : String, code : String, completionHandlerRet:(T.Result?)->()) {
        
        let url = serverAddr + "authority/index?"
        
        let parameters: Dictionary<String, AnyObject> = ["ac":"forgetpwdImgCheck",
            "email":"\(email)",
            "imgcheckcode":"\(code)",
            "password":"\(pwd)"]
        
        reqGet(url, parameters: parameters, completionHandlerRet: completionHandlerRet)
        
    }
    
    /**
    使用邮箱注册验证码校验
    
    :param: email                邮箱
    :param: pwd                  密码
    :param: code                 验证码
    :param: completionHandlerRet 回调
    */
    static public func emailCodeCheck(email : String, pwd : String, code : String, completionHandlerRet:(T.Result?)->()) {
        
        let url = serverAddr + "authority/index?"
        
        let parameters: Dictionary<String, AnyObject> = ["ac":"forgetpwdImgCheck",
            "email":"\(email)",
            "imgcheckcode":"\(code)",
            "password":"\(pwd)",
            "isregist" : "1"]
        
        reqGet(url, parameters: parameters, completionHandlerRet: completionHandlerRet)
        
    }
    
    /**
    游戏专区
    
    :param: pagenum              页码
    :param: pagesize             页大小
    :param: completionHandlerRet 回调
    
    web接口: http://cavytest.tunshu.com/mobileIndex/index?ac=prefecture&pagesize=10&pagenum=1
    */
    static public func prefectureInfo(pagenum : Int, pagesize : Int, completionHandlerRet : (T.Result?)->()) {
        
        let url = serverAddr + "mobileIndex/index?"
        
        let parameters: Dictionary<String, AnyObject> = ["ac":"prefecture",
            "pagenum":"\(pagenum)",
            "pagesize":"\(pagesize)"]
        
        reqGet(url, parameters: parameters, completionHandlerRet: completionHandlerRet)
        
    }
    
    /**
    获取专区游戏列表
    
    :param: preId                专区号
    :param: pagenum              页码
    :param: pagesize             页大小
    :param: completionHandlerRet 回调
    
    web接口：http://cavytest.tunshu.com/appIndex/index?ac=getpergames&pagesize=5&pagenum=1&preId=1
    */
    static public func prefectureList(preId : Int, pagenum : Int, pagesize : Int, completionHandlerRet : (T.Result?)->()) {
        
        let url = serverAddr + "appIndex/index?"
        
        let parameters: Dictionary<String, AnyObject> = ["ac":"getpergames",
            "pagenum":"\(pagenum)",
            "pagesize":"\(pagesize)",
            "preId":"\(preId)"]
        
        reqGet(url, parameters: parameters, completionHandlerRet: completionHandlerRet)
        
    }
    
    /**
    分类请求
    
    - parameter completionHandlerRet: 回调
    */
    static public func getClassificationInfo(completionHandlerRet: (T.Result?)->()) {
        
        let url = serverAddr + "mobileIndex/index?"
        
        let parameters = ["ac":"newclassification"]
        
        reqGet(url, parameters: parameters, completionHandlerRet: completionHandlerRet)
        
    }
    
}
