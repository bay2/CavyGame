//
//  DownloadViewController.h
//  CavyGame
//
//  Created by longjining on 15/7/23.
//  Copyright (c) 2015年 York. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DownloadViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property(weak, nonatomic) IBOutlet UITableView *downloadTable;
@property(weak, nonatomic) IBOutlet UILabel *emptydownLb;

@end
