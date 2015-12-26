//
//  DownloadButton.h
//  CavyGame
//
//  Created by D.K_奇 on 15/8/19.
//  Copyright (c) 2015年 com.lvwenhan. All rights reserved.
//

#import <UIKit/UIKit.h>

#define STATUS_Down 1001      // 下载、继续
#define STATUS_Continue 1002  // 安装、打开
#define STATUS_Pause 1003     // 暂停、重试

@interface DownloadButton : UIButton
{
    int btnStd;
}

-(void)initBnt;
/**设置按钮不同状态下的背景，3种状态*/
- (void) setButtonImageStatus:(NSInteger) status;
- (UIImage *) buttonImageFromColor:(UIColor *)color;

@end
