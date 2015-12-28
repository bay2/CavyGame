//
//  Down_Interface.m
//  CavyGame
//
//  Created by D.K_奇 on 15/8/17.
//  Copyright (c) 2015年 com.lvwenhan. All rights reserved.
//

#import "Down_Interface.h"
#import "Constants.h"
#import "DownloadViewController.h"
#import "DownloadItem.h"
#import "DownloadManager.h"
#import "EUtils.h"
#import "ProgressHUD.h"
#import "HTTPServer.h"
#import "SqliteManager.h"
#import <AVFoundation/AVAudioSession.h>
#import "Reachability.h"
#import "SwiftCavyGame-swift.h"

#if DEBUG
#define DOWNCNTURL @"http://115.28.144.243/gamecenter/appIndex/index?ac=downcount&gameid="
#else
#define DOWNCNTURL @"http://game.tunshu.com/appIndex/index?ac=downcount&gameid="
#endif



#define SETTING_KEY_DOWNINWIFI @"wifi"

@interface Down_Interface()
{
    NSDictionary * itemDicData;
}

@end

@implementation Down_Interface

static HTTPServer *httpServer = nil; // httpserver必须声明成静态的，否则安装后一直停留在等待安装...
static Reachability *rchaBility = nil;

+(Down_Interface*)getInstance
{
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{instance = self.new;});
    return instance;
}

- (void) sqliteInit
{
    [self startHttpServer];
    [[SqliteHelper sharedInstance] createTableNoidUnique:[[DownloadItem alloc] init]];
    
    [[SqliteManager sharedInstance] initDowningData];
    
    [self startDownFile];
}

-(void)startDownFile{
    
    NSMutableArray* dataList = [[SqliteManager sharedInstance]queryDownData:[[DownloadItem alloc] init] withSta:DOWNSTD_PAUSE];
    
    DownloadItem *it=nil;
    if (dataList != nil && dataList.count > 0) {
        for (int i = 0; i < dataList.count; i++) {
            it = (DownloadItem *)[dataList objectAtIndex:i];
            
            [[DownloadManager getInstance] download:it withRestart:YES];
        }
    }
    
    dataList = [[SqliteManager sharedInstance] queryDownData:[[DownloadItem alloc] init] withSta:DOWNSTD_DOWNED];
    
    if (dataList != nil && dataList.count > 0) {
        [DownloadManager getInstance].finishedItems = [[NSMutableArray alloc] initWithArray:dataList];
    }
}

-(void)startHttpServer{
    
    //  BOOL ret = [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"itms-services://?action=download-manifest&url=https://git.oschina.net/panko/caven/raw/master/CavyGameDown.plist"]];
    [self starReachWifi];
    
    httpServer = [[HTTPServer alloc] init];
    [httpServer setType:@"_http._tcp."];
    [httpServer setPort:12015];
    
    //  NSString * webLocalPath1 = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Web"];
    
    NSString *webLocalPath = [NSString stringWithFormat:@"%@/Documents/", NSHomeDirectory()];
    [httpServer setDocumentRoot:webLocalPath];
    
    NSLog(@"Setting document root: %@", webLocalPath);
    
    NSError * error;
    if([httpServer start:&error]){
        NSLog(@"start server success in port %d %@",[httpServer listeningPort],[httpServer publishedName]);
        return;
    }else{
        NSLog(@"启动http失败");
    }
    
}

-(void)starReachWifi{
    
    if (rchaBility != nil) {
        return;
    }
    ///开启网络状况的监听
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    rchaBility = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    
    [rchaBility startNotifier]; //开始监听，会启动一个run loop
}

//通知
-(void)reachabilityChanged:(NSNotification*)note
{
    Reachability * reach = [note object];
    NSParameterAssert([reach isKindOfClass: [Reachability class]]);
    NetworkStatus status = [reach currentReachabilityStatus];
    
    if (status == NotReachable) {
      //  UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:localizedString(@"networkisdown") delegate:nil cancelButtonTitle:localizedString(@"alert_Location_okButtonTitle") otherButtonTitles:nil];
     //   [alertView show];
        NSLog(@"Notification Says Unreachable");
    }else if(status == ReachableViaWWAN){
        
        
      //  UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"移动网络" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
     //   [alertView show];
        NSLog(@"Notification Says mobilenet");
    }else if(status == ReachableViaWiFi){
        
     //   UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"WIfi网络" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
     //   [alertView show];
        NSLog(@"Notification Says wifinet");
    }
    
}

/**检查是否已下载或重新下载*/
-(BOOL)checkHaveDown:(NSString*)downurl{
    
    NSMutableArray *items = [DownloadManager getInstance].items;
    for (int i=0; i < items.count; i++) {
        DownloadItem *it = [items objectAtIndex:i];
        if ([it.downurl compare:downurl] == NSOrderedSame) {//已经存在下载任务
            if ([it.operation isPaused]) {//任务暂停，则启动
                it.downloadStatus = CAGDownloadStatusDownloading;
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [ProgressHUD showSuccess:localizedString(@"download_continute")];
                });
                [it.operation resume];
                return true;
            }else{
                if ([it.operation isExecuting]) {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [ProgressHUD showSuccess:localizedString(@"downloading")];
                    });
                    return true;
                }else{
                    // 如果网络异常后 继续下载要重新创建下载任务
                    if (it.downloadStatus == CAGDownloadStatusFailure) {
                        [[DownloadManager getInstance]addOperation:it withRestart:NO];
                    }else{
                        [it.operation start];
                    }
                    
                    it.downloadStatus = CAGDownloadStatusDownReady;
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [ProgressHUD showSuccess:localizedString(@"download_continute")];
                    });
                    return true;
                }
            }
        }
    }
    
    return false;
}

/**下载文件*/
-(void)downFile:(NSDictionary*)dicData{
//    NSError *jsonError;
//    NSDictionary* json =[NSJSONSerialization
//                         JSONObjectWithData:data
//                         options:kNilOptions
//                         error:&jsonError];
//    
//    NSDictionary *dicData = [json objectForKey:@"data"];
    
    if (dicData == nil) {
        return;
    }else{
        DownloadItem *item = [DownloadItem alloc];
        item.title = [dicData objectForKey:@"gamename"];
        item.version = [dicData objectForKey:@"version"];
        item.downurl = [dicData objectForKey:@"downurl"];
        item.plisturl = [dicData objectForKey:@"plisturl"];
        item.packagename = [dicData objectForKey:@"pageName"];
        item.size =  [[dicData objectForKey:@"filesize"] integerValue];
        item.icon = [dicData objectForKey:@"icon"];
        item.gameid = [dicData objectForKey:@"gameid"];
        item.stdForSql = DOWNSTD_DOWNING;
        //item.delegate = self;
        if ([self checkHaveDown:item.downurl]) {
            NSLog(@"已存在下载列表");
            return;
        }
        
        bool bHaveRet = [[SqliteManager sharedInstance]querydata:item.gameid withstd:DOWNSTD_DOWNED];
        
        if (bHaveRet) {
            // 如果是已下载完则安装
            [ProgressHUD showError:localizedString(@"downloaded")];
            return;
        }
        
        bHaveRet = [[SqliteManager sharedInstance]querydata:item.gameid withstd:-1];
        if (bHaveRet) {
            return;
        }
        
        [self downCount:item.gameid];
        
        [[SqliteManager sharedInstance] insert:item];
        
        [[DownloadManager getInstance] download:item withRestart:NO];
    }
}
/**开始下载文件*/
-(void) downCount:(NSString*)gameid{
    
    NSString *identifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    NSString *curDevice = [[UIDevice currentDevice] localizedModel];
    NSString *sysVer = [[UIDevice currentDevice] systemVersion];
    NSString *deviceMachineIDs = [UIDevice deviceModelDataForMachineIDs];
    
    NSString *deviceInfo = [[NSString alloc] initWithFormat:@"%@, %@, %@", curDevice, deviceMachineIDs, sysVer];
    
    
    
    NSString *downURL = [[NSString alloc] initWithFormat:@"%@%@&phonetype=ios&devinfo=%@&serial=%@", DOWNCNTURL, gameid, identifier, deviceInfo];
    downURL = [downURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:downURL]];
    [request setHTTPMethod:@"GET"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"result:%@", result);
        
        if (nil == result || nil != connectionError)
        {
            NSLog(@"get file detail failed.: result[%@], connectionError[%@]", result, connectionError);
        }
    }];
}

- (DownloadItem *) downFishItems_gameid:(NSString *) gameid
{
    DownloadItem *findIt = nil;
    
    for (DownloadItem *it in [DownloadManager getInstance].items){
        if ([it.gameid compare:gameid] == NSOrderedSame){
            findIt = it;
            return findIt;
        }
    }
    
    for (DownloadItem *it in [DownloadManager getInstance].finishedItems){
        if ([it.gameid compare:gameid] == NSOrderedSame){
            findIt = it;
            return findIt;
        }
    }
    
   return findIt;
}

-(BOOL)isNotReachable{
 
    NetworkStatus status = [rchaBility currentReachabilityStatus];
    
    if (status == NotReachable) {
        return true;
    }else{
        return false;
    }
}

- (void) buttonClicked:(NSDictionary *)dicData
{
    itemDicData = dicData;
    
    NSString* gameID = [itemDicData objectForKey:@"gameid"];
    DownloadItem *item = [self downFishItems_gameid:gameID];

    BOOL isAlertWifi = [[NSUserDefaults standardUserDefaults]boolForKey:SETTING_KEY_DOWNINWIFI];

    NetworkStatus status = [rchaBility currentReachabilityStatus];

    if (status == NotReachable) {
        return;
    }
    
    // 非wifi 并且是下载 继续
    if (isAlertWifi && status != ReachableViaWiFi && (item == nil || item.downloadStatus == CAGDownloadStatusPause || item.downloadStatus == CAGDownloadStatusFailure || item.downloadStatus == CAGDownloadStatusUpdate)) {
        
        UIAlertView *alvertView=[[UIAlertView alloc]initWithTitle:localizedString(@"alert_Wifi_Title")
                                                          message:localizedString(@"alert_Wifi_msg")
                                                         delegate:self
                                                cancelButtonTitle:localizedString(@"alert_Wifi_continuButtonTitle")
                                                otherButtonTitles:localizedString(@"alert_Wifi_cancelButtonTitle"),nil];
        [alvertView show];
        return;
    }else{
        [self downItem];
    }
}

-(void)downItem{
    
    if (itemDicData == nil) {
        return;
    }else{
        NSString* gameID = [itemDicData objectForKey:@"gameid"];
        DownloadItem *item = [self downFishItems_gameid:gameID];
        
        if (item == nil){
            [self downFile:itemDicData];
        }else{
            for (DownloadItem *it in [DownloadManager getInstance].finishedItems){
                if ([it.downurl compare:item.downurl] == NSOrderedSame){
                    item = it;
                    break;
                }
            }
            if (item.operation != nil){
            }else{
                for (DownloadItem *it in [DownloadManager getInstance].items){
                    
                    if ([it.downurl compare:item.downurl] == NSOrderedSame){
                        item = it;
                        break;
                    }
                }
            }
            
//            if (it.downloadStatus == CAGDownloadStatusUpdate) {
//                
//                [self downCount:item.gameid];
//                
//                [[SqliteManager sharedInstance] insert:item];
//            }
            
            
            if (item.downloadStatus == CAGDownloadStatusDownloading || item.downloadStatus == CAGDownloadStatusDownReady){
                [[DownloadManager getInstance]downloadBtnClicked:item];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"Pause_%@", item.gameid] object:nil];
                
            } else if (item.downloadStatus == CAGDownloadStatusPause || item.downloadStatus == CAGDownloadStatusFailure ) {
                [[DownloadManager getInstance]downloadBtnClicked:item];
                [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"Downloading_%@", item.gameid] object:nil];
                
                
            } else if (item.downloadStatus == CAGDownloadStatusUpdate) {
                
                [self downCount:item.gameid];
                
                [[SqliteManager sharedInstance] updata:item.gameid withplist:[itemDicData objectForKey:@"plisturl"]];
                item.plisturl = [itemDicData objectForKey:@"plisturl"];
                
                [[DownloadManager getInstance]downloadBtnClicked:item];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"Downloading_%@", item.gameid] object:nil];
                
            } else {
                //安装代码
                [[DownloadManager getInstance]install:item.plisturl];
            }
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"ContinueInGPRS_%@", gameID] object:nil];
    }
}

#pragma marks -- UIAlertViewDelegate --
//根据被点击按钮的索引处理点击事件
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        // 继续
        [self downItem];
    }else{
        return;
    }
}
@end
