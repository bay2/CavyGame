//
//  DownloadButton.m
//  CavyGame
//
//  Created by D.K_奇 on 15/8/19.
//  Copyright (c) 2015年 com.lvwenhan. All rights reserved.
//

#import "DownloadButton.h"
#import "Constants.h"

#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f \
blue:(b)/255.0f alpha:1.0f]

@implementation DownloadButton

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self){
        [self initBnt];
    }
    return self;
}

-(void)initBnt{
    self.backgroundColor = [UIColor clearColor];
  //  [UIButton buttonWithType:UIButtonTypeCustom];
    self.layer.masksToBounds = YES;
    
    if (CAG_MainScreenWidth == 320) {
        self.layer.cornerRadius = 4;
    }else{
        self.layer.cornerRadius = 6;
    }
}

- (void) setButtonImageStatus:(NSInteger) status
{
    
    if (btnStd == status) {
        
        return;
    }
    
    btnStd = status;
    
    switch (status) {
        case STATUS_Down:{//下载
            self.layer.borderColor = RGBCOLOR(0x3e, 0x76, 0xdb).CGColor;
            self.layer.borderWidth = 1;
            // 0x56, 0x8a, 0xe8
            [self setTitleColor:RGBCOLOR(0x3e, 0x76, 0xdb) forState:UIControlStateNormal];
            [self setTitleColor:RGBCOLOR(0xff, 0xff, 0xff) forState:UIControlStateHighlighted];
            
            [self setBackgroundImage:[self buttonImageFromColor:RGBCOLOR(0xff, 0xff, 0xff)] forState:UIControlStateNormal];
            [self setBackgroundImage:[self buttonImageFromColor:RGBCOLOR(0x3e, 0x76, 0xdb)] forState:UIControlStateHighlighted];

        }
            break;
            
        case STATUS_Continue:{//继续、安装、打开、重试
            self.layer.borderColor = [UIColor clearColor].CGColor;
            self.layer.borderWidth = 0;
            
            [self setTitleColor:RGBCOLOR(0xff, 0xff, 0xff) forState:UIControlStateNormal];
            [self setTitleColor:RGBCOLOR(0xff, 0xff, 0xff) forState:UIControlStateHighlighted];
            
            [self setBackgroundImage:[self buttonImageFromColor:RGBCOLOR(0x56, 0x8a, 0xe8)] forState:UIControlStateNormal];
            [self setBackgroundImage:[self buttonImageFromColor:RGBCOLOR(0x3e, 0x76, 0xdb)] forState:UIControlStateHighlighted];
        }
            break;
            
        case STATUS_Pause:{//暂停
            self.layer.borderColor = [UIColor clearColor].CGColor;
            self.layer.borderWidth = 0;
            
            [self setTitleColor:RGBCOLOR(0x4c, 0x4c, 0x4c) forState:UIControlStateNormal];
            [self setTitleColor:RGBCOLOR(0x4c, 0x4c, 0x4c) forState:UIControlStateHighlighted];
            
            [self setBackgroundImage:[self buttonImageFromColor:RGBCOLOR(0xe6, 0xe6, 0xe6)] forState:UIControlStateNormal];
            [self setBackgroundImage:[self buttonImageFromColor:RGBCOLOR(0xb6, 0xb6, 0xb6)] forState:UIControlStateHighlighted];
        }
            break;
            
        default:
            break;
    }
}

- (UIImage *) buttonImageFromColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

@end
