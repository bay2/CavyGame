//
//  DownloadManager.m
//  CavyGame
//
//  Created by York on 7/8/15.
//  Copyright (c) 2015 York. All rights reserved.
//

#import "DownloadManager.h"
#import "SqliteManager.h"
#import "AFDownloadRequestOperation.h"
#import "ProgressHUD.h"
#import "Constants.h"

#define SETTING_KEY_INSTALL @"install"

#define DocumentsDirectory [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) lastObject]
@interface DownloadManager (){
    
//    AFURLSessionManager *_manager;
//    NSURLSession *_session;
//    

}@end

@implementation DownloadManager




+(DownloadManager*)getInstance
{
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{instance = self.new;});
    return instance;
}

- (id)init
{
    if ((self = [super init]))
    {
        self.items = [NSMutableArray arrayWithCapacity:100];
        if (self.finishedItems == nil) {
            self.finishedItems = [NSMutableArray arrayWithCapacity:100];
        }
//        NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
//        _manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:config];

    }
    return self;
}

//获取已下载的文件大小
- (unsigned long long)fileSizeForPath:(NSString *)path {
    signed long long fileSize = 0;
    NSFileManager *fileManager = [NSFileManager new]; // default is not thread safe
    if ([fileManager fileExistsAtPath:path]) {
        NSError *error = nil;
        NSDictionary *fileDict = [fileManager attributesOfItemAtPath:path error:&error];
        if (!error && fileDict) {
            fileSize = [fileDict fileSize];
        }
    }
    return fileSize;
}


/*
 
 ** 是否需要更新
 */
-(void)needUpdate:(NSString*)gameid version : (NSString*)curVersion downUrl : (NSString*)url{
    
    // 如果下载完了 且版本较低则显示更新
    for (DownloadItem *it in [DownloadManager getInstance].finishedItems){
        if (!it.isCheckUpdate && [it.gameid compare:gameid] == NSOrderedSame){
            
            it.isCheckUpdate = true;
            if (curVersion.intValue > it.version.intValue) {
                it.version = curVersion;
                it.downloadStatus = CAGDownloadStatusUpdate;
                it.downurl = url;
                return;
            }
        }
    }
}

-(void)deleteIPA:(NSString*)name{
    
    // name [it.downurl lastPathComponent]
    NSString *filePath = [NSString stringWithFormat:@"%@/Documents/%@", NSHomeDirectory(),
                          name];
    NSFileManager *manager = [NSFileManager defaultManager];
    [manager removeItemAtPath:filePath error:nil];
}

- (CAGDownloadAddResult)download:(DownloadItem *)item withRestart:(BOOL)isRestart
{
    for (int i=0; i < [self.items count]; i++) {
        DownloadItem *it = [self.items objectAtIndex:i];
        if ([it.downurl compare:item.downurl] == NSOrderedSame) {//已经存在下载任务
            if ([it.operation isPaused]) {//任务暂停，则启动
                [it.operation resume];
                return CAGDownloadAddResultOK;
            }else{//如果正在下载，则返回no
                if ([it.operation isExecuting]) {
                    return CAGDownloadAddResultExist;
                }else{
                    [it.operation start];
                    return CAGDownloadAddResultOK;
                }
            }
        }
    }

    return [self addOperation:item withRestart:isRestart];
}

-(void)downloadBtnClicked:(DownloadItem *)item{
    
    if (item.downloadStatus == CAGDownloadStatusDownloading || item.downloadStatus == CAGDownloadStatusDownReady){
        [item.operation pause];
        item.downloadStatus = CAGDownloadStatusPause;

    } else if (item.downloadStatus == CAGDownloadStatusPause || item.downloadStatus == CAGDownloadStatusFailure || item.downloadStatus == CAGDownloadStatusUpdate) {
        
        if (item.downloadStatus != CAGDownloadStatusPause) {
            [item.operation setValue:@"0" forKey:@"totalBytesRead"];
        }
        
        if (item.downloadStatus == CAGDownloadStatusUpdate)
        {
            // 更新 删除ipa 修改下载状态 (包括db)
            [[DownloadManager getInstance]deleteIPA:[item.downurl lastPathComponent]];
            [[DownloadManager getInstance].finishedItems removeObject:item];
            [[DownloadManager getInstance].items addObject:item];
        }
        
        // 如果网络异常后 继续下载要重新创建下载任务
        if (item.downloadStatus == CAGDownloadStatusFailure || item.downloadStatus == CAGDownloadStatusUpdate) {
            item.downloadStatus = CAGDownloadStatusDownReady;
            [[DownloadManager getInstance]addOperation:item withRestart:NO];
            [[SqliteManager sharedInstance]updata:item.gameid withstd:CAGDownloadStatusDownloading];
        }else{
            if (item.operation.isPaused) {
                [item.operation resume];
            }else{
                [item.operation start];
            }
        }
        item.downloadStatus = CAGDownloadStatusDownReady;
    }
    else //if (_item.downloadStatus == CAGDownloadStatusFinished)
    {
        //安装代码
        [self install:item.plisturl];
    }
}

-(void)install:(NSString*)url{
    NSString* downUrl = url;  // ipa plist放在同一个目录下
    
    NSRange range;
    range = [downUrl rangeOfString:@"https"];
    if (range.location == NSNotFound) {
        downUrl = [downUrl stringByReplacingOccurrencesOfString:@"http" withString:@"https"];
    }
    /*
    downUrl = [downUrl stringByReplacingOccurrencesOfString:@".ipa" withString:@".plist"];
    */
    
    NSString *plistUrl = [[NSString alloc] initWithFormat:@"itms-services://?action=download-manifest&url=%@", downUrl];
    
    //   NSString *plistUrl = [[NSString alloc] initWithFormat:@"itms-services://?action=download-manifest&url=https://git.oschina.net/panko/caven/raw/master/%@.plist", _item.gameid];
    
    BOOL ret = [[UIApplication sharedApplication]openURL:[NSURL URLWithString:plistUrl]];
    
    if (ret == NO) {
        [ProgressHUD showError:localizedString(@"install_fail")];
    }
}

// 下载完成后自动安装
-(void)autoInstall:(NSString*)url{
    
    BOOL isAutoInstall = [[NSUserDefaults standardUserDefaults]boolForKey:SETTING_KEY_INSTALL];
    
    if (isAutoInstall) {
        [self install:url];
    }
}

-(CAGDownloadAddResult)addOperation:(DownloadItem *)item withRestart:(BOOL)isRestart{
    NSURL *url = [NSURL URLWithString:item.downurl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setTimeoutInterval:0];
    //不使用缓存，避免断点续传出现问题
    [[NSURLCache sharedURLCache] removeCachedResponseForRequest:request];
    
    NSString *filename = [item.downurl lastPathComponent];
    
    //  NSString *filePath = [NSString stringWithFormat:@"%@/Documents/%@", NSHomeDirectory(),filename];
    
    NSString *filePath = [DocumentsDirectory stringByAppendingPathComponent:filename];
    AFDownloadRequestOperation *operation = [[AFDownloadRequestOperation alloc] initWithRequest:request targetPath:filePath shouldResume:YES];
    
    item.downloadLength = [self fileSizeForPath:filePath];
    
    //设置下载进度条
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        
        //显示下载进度
        
        //  CGFloat progress = ((float)totalBytesRead) / totalBytesExpectedToRead;
        //  [downProgressView setProgress:progress animated:YES];
        [item downloadProgress:bytesRead withTotalBytesRead:totalBytesRead withTotalBytesExpectedToRead:totalBytesExpectedToRead];
    }];
    
    //请求管理判断请求结果
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //请求成功
        NSLog(@"Finish and Download to: %@", filePath);
        //NSLog(@"===%.2f", (float)item.downloadLength / 1048576);
        //[item downloadCompletionBlockWithSuccess:operation withId:responseObject];
        item.downloadLength = item.size;
        item.downloadStatus = CAGDownloadStatusFinished;
        
        NSMutableDictionary *dicData = [[NSMutableDictionary alloc] init];
        [dicData setObject:item.title forKey:@"gamename"];
        [dicData setObject:item.version forKey:@"version"];
        [dicData setObject:item.downurl forKey:@"downurl"];
        [dicData setObject:item.packagename forKey:@"pageName"];
        [dicData setObject:[NSString stringWithFormat:@"%ld", (long)item.size] forKey:@"filesize"];
        [dicData setObject:item.icon forKey:@"icon"];
        [dicData setObject:item.gameid forKey:@"gameid"];
        [dicData setObject:@"3" forKey:@"downloadStatus"];//成功
        [dicData setObject:[NSString stringWithFormat:@"%ld", (long)item.size] forKey:@"downloadLength"];
        [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"%@", item.gameid] object:dicData];
        dicData = nil;
        
        [self.items removeObject:item];
        [self.finishedItems addObject:item];
        if (self.tableView) {
            [self.tableView reloadData];
        }
        
    //    [[SqliteManager sharedInstance] updata:item.gameid withstd:DOWNSTD_DOWNED withDownStd:CAGDownloadStatusFinished];
        [[SqliteManager sharedInstance] updata:item.gameid withstd:DOWNSTD_DOWNED withDownStd:CAGDownloadStatusFinished version:item.version.intValue];
        
        
        [self autoInstall:item.plisturl];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        //请求失败
        [operation setValue:@"0" forKey:@"totalBytesRead"];
        NSLog(@"Download Error: %@",error.localizedDescription);
        [operation cancel];
        if (item.downloadStatus != CAGDownloadDeleting) {
            item.downloadStatus = CAGDownloadStatusFailure;
            [item downloadFailure:operation withError:error];
            
            [[SqliteManager sharedInstance]updata:item.gameid withstd:DOWNSTD_PAUSE];
        }
    }];
    
    item.operation =  operation;
    item.localFile = filename;
    
    if (isRestart) {
        item.downloadStatus = CAGDownloadStatusPause;
    }else{
        [operation start];
        item.downloadStatus = CAGDownloadStatusDownReady;
    }
    
    for (int i=0; i < [self.items count]; i++) {
        DownloadItem *it = [self.items objectAtIndex:i];
        if ([it.downurl compare:item.downurl] == NSOrderedSame) {//已经存在下载列表中
            return CAGDownloadAddResultOK;
        }
    }
    
    [self.items addObject:item];
    
    return CAGDownloadAddResultOK;
}
@end
