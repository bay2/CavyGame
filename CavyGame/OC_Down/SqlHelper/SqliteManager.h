//
//  SqliteManager.h
//  CavyGame
//
//  Created by longjining on 15/7/20.
//  Copyright (c) 2015年 York. All rights reserved.
//

#ifndef CavyGame_SqliteManager_h
#define CavyGame_SqliteManager_h
#import "SqliteHelper.h"

#define DOWNSTD_DOWNING 0
#define DOWNSTD_PAUSE 1
#define DOWNSTD_DOWNED 2

@class DownloadItem;
@interface SqliteManager : NSObject

+ (SqliteManager *)sharedInstance;

-(NSMutableArray *)queryData:(id)entity withSql:(NSString *)sql withArray:(NSArray *)array;

// 查找下载的文件
/*
 std:0 正在下载 1 暂停 2 已下载
 */
-(NSMutableArray *)queryDownData:(id)entity withSta:(int)std;

-(bool) querydata:(NSString*)gameid withstd:(long)std;
// 初始化下载的状态为暂停
-(void)initDowningData;

-(bool) insert:(id)entity;
-(bool) deleteData:(NSString*)gameid;
-(bool) updata:(NSString*)gameid withstd:(long)std;
-(bool) updata:(NSString*)gameid withstd:(long)std  withDownStd:(int)downstd version:(int)versionNew;
-(bool) updata:(NSString*)gameid withplist:(NSString*)plist;
/**根据gameid查询DownloadItem，若已存在下载列表则返回DownloadItem数据，若无则返回nil*/
- (DownloadItem *) queryGameStd:(NSString *) gameid;
@end
#endif
