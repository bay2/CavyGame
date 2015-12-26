//
//  Down_Interface.h
//  CavyGame
//
//  Created by D.K_奇 on 15/8/17.
//  Copyright (c) 2015年 com.lvwenhan. All rights reserved.
//下载功能接口

#import <Foundation/Foundation.h>

@class DownloadItem;
@interface Down_Interface : NSObject

+(Down_Interface*)getInstance;
/**sqlite初始化*/
- (void) sqliteInit;

/**下载文件，传入下载文件的字典类型数据**/
-(void)downFile:(NSDictionary*)dicData;
/**根据gameid查询DownloadItem，若已存在下载列表则返回DownloadItem数据，若无则返回nil*/
- (DownloadItem *) downFishItems_gameid:(NSString *) gameid;
/**下载按钮响应接口，传入对应的字典类型数据*/
- (void) buttonClicked:(NSDictionary *) dicData;

// 网络是否不可用
-(BOOL)isNotReachable;
@end
