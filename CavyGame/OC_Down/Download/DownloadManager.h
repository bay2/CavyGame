//
//  DownloadManager.h
//  CavyGame
//
//  Created by York on 7/8/15.
//  Copyright (c) 2015 York. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "DownloadItem.h"

typedef NS_ENUM(NSInteger, CAGDownloadAddResult) {
    CAGDownloadAddResultOK,
    CAGDownloadAddResultExist,
    CAGDownloadAddResultExistAndFinished
};


@interface DownloadManager : NSObject


@property (nonatomic,strong)  NSMutableArray *items;
@property (nonatomic,strong)  NSMutableArray *finishedItems;
@property (nonatomic,strong)  UITableView *tableView;

+(DownloadManager*)getInstance;
- (CAGDownloadAddResult)download:(DownloadItem *)item withRestart:(BOOL)isRestart/*是否是app启动添加的*/;
-(CAGDownloadAddResult)addOperation:(DownloadItem *)item withRestart:(BOOL)isRestart;
-(void)needUpdate:(NSString*)gameid version : (NSString*)curVersion downUrl : (NSString*)url;
-(void)deleteIPA:(NSString*)name;
-(void)downloadBtnClicked:(DownloadItem *)item;
-(void)install:(NSString*)url;
@end
