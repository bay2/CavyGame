//
//  DUListCell.h
//  CloudDisk
//
//  Created by York on 13-12-18.
//  Copyright (c) 2013年 SAE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DownloadItem.h"

#define DOWMTABLEHIGHT 157
#define IOS5_CELL_HIGHT 93.5

@interface DownloadCell : UITableViewCell<DownloadDelegate>

@property (nonatomic, strong) UIView *baskView;
//@property(nonatomic,strong) DownloadItem *item;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
-(void)updateView;
-(void)setWattingText;
-(void)setDownloadItem:(DownloadItem *)item;

- (void)downloadProgress:(NSUInteger)bytesRead withTotalBytesRead:(long long)totalBytesRead withTotalBytesExpectedToRead:(long long)totalBytesExpectedToRead;
- (void)downloadCompletionBlockWithSuccess:(AFHTTPRequestOperation *)operation withId:(id)responseObject;
- (void)downloadFailure:(AFHTTPRequestOperation *)operation withError:(NSError *)error;

@end
