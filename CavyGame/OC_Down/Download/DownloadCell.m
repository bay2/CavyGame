//
//  DUListCell.m
//  CloudDisk
//
//  Created by York on 13-12-18.
//  Copyright (c) 2013年 SAE. All rights reserved.
//


#import "DownloadCell.h"
#import "Constants.h"
#import "EUtils.h"
#import "dlfcn.h"
#import <Foundation/Foundation.h>
#import "UIImageView+WebCache.h"
#import "ProgressHUD.h"
//#import "AppDelegate.h"
#import "DownloadManager.h"
#import "DownloadButton.h"
#import "Reachability.h"
#import "Down_Interface.h"

#define BTNBACKCOLOR_BLUE colorWithRGB(87,194,242,255)

#define SETTING_KEY_DOWNINWIFI @"wifi"

@interface DownloadCell ()
{
    UIImageView *_iconImageView;
    UILabel *_fileNameLabel;
    UILabel *_fileLoadFinshedLabel;
    UILabel *_lengthLabel;
    UILabel *_loadinghlengthLabel;
    DownloadButton *_downloadBtn;
    UIProgressView *_progressView;
    CGRect _fileNameLabelOriginRect;
    CGRect _fileNameLabelFinishedRect;
    CGRect _fileLoadFinshedRect;
    CGRect _downloadBtnOriginRect;
    CGRect _downloadBtnFinishedRect;
    CGRect _loadinglengthFrame;
    
    DownloadItem *_item;
    UILabel *lineLabel;
    
    long long _totalBytesExpectedToRead;
    
    long long _downloadLengthInit;
}
@end



@implementation DownloadCell
@synthesize baskView = _baskView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIView *backColorView = [[UIView alloc] initWithFrame:self.frame];
        backColorView.backgroundColor = colorWithHexStr(@"#eeeeee");
        self.backgroundView = backColorView;
        backColorView = nil;
        
        _baskView = [[UIView alloc] initWithFrame:self.frame];
        _baskView.backgroundColor = colorWithHexStr(@"#ffffff");
        [self.contentView addSubview:_baskView];
        
        lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 1, CAG_MainScreenWidth, 1)];
        lineLabel.backgroundColor = colorWithHexStr(@"#d4d4d4");
        [self.contentView addSubview:lineLabel];
        
        [self viewInit];
    }
    return self;
}

// ios7.0 的删除按钮需要特殊处理 begin
-(void)willTransitionToState:(UITableViewCellStateMask)state{

    [super willTransitionToState:state];
    
    if (IS_IOS8) {
        return;
    }
    if((state & UITableViewCellStateShowingDeleteConfirmationMask) == UITableViewCellStateShowingDeleteConfirmationMask){
        [self recurseAndReplaceSubViewIfDeleteConfirmationControl:self.subviews];
        [self performSelector:@selector(recurseAndReplaceSubViewIfDeleteConfirmationControl:) withObject:self.subviews afterDelay:0];
    }
}

-(void)recurseAndReplaceSubViewIfDeleteConfirmationControl:(NSArray*)subviews{
    for (UIView *subview in subviews)
    {
        NSLog(@"%@", NSStringFromClass([subview class]));
        //the rest handles ios7
        if ([NSStringFromClass([subview class]) isEqualToString:@"UITableViewCellDeleteConfirmationButton"])
        {
            UIButton *deleteButton = (UIButton *)subview;
            
            NSString* deleteText = localizedString(@"deleteText");

            [deleteButton setTitle:deleteText forState:UIControlStateNormal];

            [self setDeleteBtnFrame:deleteButton];
        }
        
        if ([NSStringFromClass([subview class]) isEqualToString:@"UITableViewCellScrollView"])
        {
            [subview setBackgroundColor:colorWithHexStr(@"#ebebeb")];
        }
        
        if([subview.subviews count]>0){
            [self recurseAndReplaceSubViewIfDeleteConfirmationControl:subview.subviews];
        }
    }
}

-(void)setDeleteBtnFrame:(UIView*)delView{
    
    delView.backgroundColor = [UIColor redColor];
    CGRect rect = delView.frame;
    rect.size.height = _baskView.frame.size.height;
    rect.origin.y = _baskView.frame.origin.y;
    if (delView.superview) {
        delView.superview.backgroundColor = colorWithHexStr(@"#ebebeb");;
    }
    delView.frame = rect;
}
// end ios7.0 的删除按钮需要特殊处理

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // 修改删除按钮的高度及y坐标
    for (UIView *subView in self.subviews) {
        
        if ([NSStringFromClass([subView class]) isEqualToString:@"UITableViewCellDeleteConfirmationView"]) {
            // ios7.0的无法使用此方法
            UIView * delView = (UIView *)[subView.subviews firstObject];
            delView.backgroundColor = [UIColor redColor];
            CGRect rect = delView.frame;
            rect.size.height = _baskView.frame.size.height;
            rect.origin.y = _baskView.frame.origin.y;
            if (delView.superview) {
                delView.superview.backgroundColor = [UIColor clearColor];
            }
            delView.frame = rect;
        }
    }
}

-(void)viewInit
{
    CGFloat iconTopY= 13;//(download_cell_height-download_cell_icon_size)/download_cell_icon_spacing;
    CGFloat btnTopY = 33;
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGSize size = rect.size;
    CGFloat height = size.height;
    
    if (height == 568.0) {
        iconTopY = 8;
    }
    
    _iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(download_cell_left_x, iconTopY, download_cell_icon_size, download_cell_icon_size)];
    _iconImageView.backgroundColor=[UIColor clearColor];
    [_iconImageView setImage:[UIImage imageNamed:@"Icon-60@2x.png"]];
    
    _iconImageView.layer.masksToBounds = YES; //没这句话它圆不起来
    _iconImageView.layer.cornerRadius = 12.0; //设置图片圆角的尺度
    
    [_baskView addSubview:_iconImageView];
    
    _fileNameLabelOriginRect = CGRectMake(download_cell_left_x + download_cell_icon_size + 15, _iconImageView.frame.origin.y, CAG_MainScreenWidth-4*download_cell_left_x-download_cell_icon_size-download_cell_download_button_width, download_cell_name_label_height);
    
    
    _fileNameLabelFinishedRect = CGRectMake(_fileNameLabelOriginRect.origin.x,_fileNameLabelOriginRect.origin.y,_fileNameLabelOriginRect.size.width,_fileNameLabelOriginRect.size.height);
    
    _fileNameLabel = [[UILabel alloc] initWithFrame:_fileNameLabelOriginRect];
    _fileNameLabel.backgroundColor = [UIColor clearColor];
    _fileNameLabel.font = [UIFont systemFontOfSize:17];
    _fileNameLabel.textColor = [UIColor blackColor];
    _fileNameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _fileNameLabel.adjustsFontSizeToFitWidth = YES;
    [_baskView addSubview:_fileNameLabel];
    
    CGRect loadinglengthFrame= CGRectMake(_fileNameLabel.frame.origin.x, _fileNameLabel.frame.origin.y+_fileNameLabel.frame.size.height + 10, download_cell_loadinglength_label_wight, download_cell_length_label_height);
    _loadinghlengthLabel = [[UILabel alloc] initWithFrame:loadinglengthFrame];
    _loadinghlengthLabel.backgroundColor = [UIColor clearColor];
    _loadinghlengthLabel.font = [UIFont systemFontOfSize:14];
    _loadinghlengthLabel.textColor = color_download_finshed_label;
    _loadinghlengthLabel.textAlignment = NSTextAlignmentLeft;
    _loadinghlengthLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [_baskView addSubview:_loadinghlengthLabel];
    
    
    CGRect lengthFrame= CGRectMake(_fileNameLabel.frame.origin.x + _loadinghlengthLabel.frame.size.width, _fileNameLabel.frame.origin.y+_fileNameLabel.frame.size.height + 10, download_cell_length_label_wight, download_cell_length_label_height);
    _lengthLabel = [[UILabel alloc] initWithFrame:lengthFrame];
    
    _lengthLabel.backgroundColor = [UIColor clearColor];
    _lengthLabel.font = [UIFont systemFontOfSize:14];
    _lengthLabel.textColor = color_download_finshed_label;
    _lengthLabel.textAlignment = NSTextAlignmentLeft;
    _lengthLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [_baskView addSubview:_lengthLabel];
    
    _fileLoadFinshedRect = CGRectMake(_fileNameLabel.frame.origin.x, _lengthLabel.frame.origin.y + 10, download_cell_finshed_label_wight, download_cell_finshed_label_height);
    _fileLoadFinshedLabel = [[UILabel alloc] initWithFrame:_fileLoadFinshedRect];
    _fileLoadFinshedLabel.backgroundColor = [UIColor clearColor];
    _fileLoadFinshedLabel.font = [UIFont systemFontOfSize:14];
    _fileLoadFinshedLabel.textColor = color_download_finshed_label;
    _fileLoadFinshedLabel.textAlignment = NSTextAlignmentLeft;
    _fileLoadFinshedLabel.text = localizedString(@"download_finished");
    _fileLoadFinshedLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [_baskView addSubview:_fileLoadFinshedLabel];
    _fileLoadFinshedLabel.hidden = YES;
    
    if (height == 568.0) {
        btnTopY = 26;
    }
    _downloadBtnOriginRect= CGRectMake(CAG_MainScreenWidth - download_cell_download_button_width - 15, btnTopY , download_cell_download_button_width, download_cell_download_button_height);
    _downloadBtnFinishedRect = CGRectMake(_downloadBtnOriginRect.origin.x,_downloadBtnOriginRect.origin.y,_downloadBtnOriginRect.size.width,_downloadBtnOriginRect.size.height);
    
    _downloadBtn = [[DownloadButton alloc] initWithFrame:_downloadBtnOriginRect];
    //[_downloadBtn setBackgroundColor:[UIColor grayColor]];
    _downloadBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    //[_downloadBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_downloadBtn setTitle:localizedString(@"pause") forState:UIControlStateNormal];
    [_downloadBtn setButtonImageStatus:STATUS_Continue];
    [_downloadBtn addTarget:self action:@selector(downloadBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    //[_downloadBtn.layer setCornerRadius:PX_TO_PT(8.0)]; //设置矩形四个圆角半径
    
    CGRect progressFrame= CGRectMake(_fileNameLabel.frame.origin.x, _lengthLabel.frame.origin.y + _lengthLabel.frame.size.height - 3, _downloadBtnOriginRect.origin.x - _fileNameLabel.frame.origin.x - 25, 6);
    _progressView=[[UIProgressView alloc] initWithFrame:progressFrame];
    _progressView.progressViewStyle=UIProgressViewStyleBar;
    _progressView.progress=0.0;
    _progressView.progressTintColor = color_download_progress_bar;
    _progressView.trackTintColor = color_download_progress_track;
    
    //修改进度条高度
    _progressView.transform = CGAffineTransformMakeScale(1.0f, 2.0f);
    [_baskView addSubview:_progressView];
    
    
    [_baskView addSubview:_downloadBtn];
}

-(void)setDownloadItem:(DownloadItem *)item
{
    _item = item;
    _downloadLengthInit = item.downloadLength;
    _fileNameLabel.text = _item.title;
    _lengthLabel.text = [NSString stringWithFormat:@" / %.2fM",(float)_item.size];
    _loadinghlengthLabel.text = [NSString stringWithFormat:@"0.00M"];
    _progressView.progress = 0;
    
   // NSString* strIcon = [item.icon lastPathComponent];
//    UIImage* img = [UIImage imageNamed:strIcon];
//    
//    if (img != nil) {
//        [_iconImageView setImage:img];
//    }else{
//        [_iconImageView setImage:[UIImage imageNamed:@"icon_game"]];
//            
//        [self loadIConFromServer:strIcon];
//        
//    }
    
    [_iconImageView sd_setImageWithURL:[NSURL URLWithString:item.icon] placeholderImage:[UIImage imageNamed:@"icon_game"]];
    
    
    
    
}

//如果没有缓存图片，从服务器上请求
-(void)loadIConFromServer:(NSString*)strIcon{
    
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString * diskCachePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"imageCache"];
    
    //如果目录imageCache不存在，创建目录
    if (![[NSFileManager defaultManager] fileExistsAtPath:diskCachePath]) {
        NSError *error=nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:diskCachePath withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    NSString *localpath = [NSString stringWithFormat:@"%@/imageCache/%@",[paths objectAtIndex:0], strIcon];//
    
    //如果有缓存图片，直接读取cache内的缓存图片
    if ([[NSFileManager defaultManager] fileExistsAtPath:localpath]) {
        NSData *data = [NSData dataWithContentsOfFile:localpath];
        
        UIImage *headimg = [[UIImage alloc] initWithData:data];
        
        [_iconImageView setImage:headimg];
    }
    else{
        NSURL * url = [NSURL URLWithString:_item.icon];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        NSOperationQueue *que = [[NSOperationQueue alloc] init];
        [NSURLConnection sendAsynchronousRequest:request queue:que completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (connectionError) {
                NSLog(@"AsynchronousRequest1 get data is OK  on thread %@!!",[NSThread currentThread]);
            }
            else{
                
                if (data) {
                    if (![[NSFileManager defaultManager] fileExistsAtPath:localpath]) {
                        //保存图片
                        
                        [[NSFileManager defaultManager] createFileAtPath:localpath contents:data attributes:nil];
                    }
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        UIImage *headimg = [[UIImage alloc] initWithData:data];
                        
                        [_iconImageView setImage:headimg];
                    });

                }
            }
        }];

    }
}

-(CGSize)boundingRectTxt:(NSString*)txt font:(UIFont*)txtFont maxsize:(CGSize)size{
    
    CGSize labelSize;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{NSFontAttributeName:txtFont, NSParagraphStyleAttributeName:paragraphStyle.copy};
    
    labelSize = [txt boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    
    labelSize.height = ceil(labelSize.height);
    labelSize.width = ceil(labelSize.width);
    
    return labelSize;
}

-(void)updateView
{
    //[_downloadBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    lineLabel.frame = CGRectMake(0, _baskView.frame.size.height + _baskView.frame.origin.y, _baskView.frame.size.width, 1);
    _downloadBtn.enabled = YES;
    if (_item.downloadStatus == CAGDownloadStatusDownloading) {
        //下载状态
        [_downloadBtn setTitle:localizedString(@"pause") forState:UIControlStateNormal];
        //[_downloadBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        //[_downloadBtn setBackgroundColor:color_download_btn];
        [_downloadBtn setButtonImageStatus:STATUS_Pause];
        _progressView.progressTintColor = color_loading;
        _loadinghlengthLabel.textColor = color_loading;
        
    }else if (_item.downloadStatus == CAGDownloadStatusDownReady) {
        //等待状态
        [_downloadBtn setTitle:localizedString(@"pause") forState:UIControlStateNormal];
        //[_downloadBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        //[_downloadBtn setBackgroundColor:color_download_btn];
        [_downloadBtn setButtonImageStatus:STATUS_Pause];
      //  _progressView.progressTintColor = color_loading;
      //  _loadinghlengthLabel.textColor = color_loading;
        
    }
    else if (_item.downloadStatus == CAGDownloadStatusPause) {
        //暂停状态
        [_downloadBtn setTitle:localizedString(@"downcontinue") forState:UIControlStateNormal];
        //[_downloadBtn setBackgroundColor:BTNBACKCOLOR_BLUE];
        [_downloadBtn setButtonImageStatus:STATUS_Down];
        _progressView.progressTintColor = color_download_progress_bar;
        _loadinghlengthLabel.textColor = color_download_finshed_label;

    } else if (_item.downloadStatus == CAGDownloadStatusFinished ||
               _item.downloadStatus == CAGDownloadStatusUpdate)
    {//下载完成状态
        if (_item.downloadStatus == CAGDownloadStatusUpdate) {
            [_downloadBtn setTitle:localizedString(@"download_update") forState:UIControlStateNormal];
            _fileLoadFinshedLabel.text = localizedString(@"download_update_tip");
        }else{
            [_downloadBtn setTitle:localizedString(@"install") forState:UIControlStateNormal];
            _fileLoadFinshedLabel.text = localizedString(@"download_finished");
        }
        
        [_downloadBtn setButtonImageStatus:STATUS_Continue];
        [_downloadBtn setBackgroundColor:BTNBACKCOLOR_BLUE];
        
        _fileLoadFinshedLabel.textColor = color_download_finshed_label;

    }else //if (_item.downloadStatus == CAGDownloadStatusFailure)
    {//下载失败
        
        // [_downloadBtn setTitle:localizedString(@"fail") forState:UIControlStateNormal];
        [_downloadBtn setTitle:localizedString(@"download_again") forState:UIControlStateNormal];
        [_downloadBtn setButtonImageStatus:STATUS_Pause];
        //[_downloadBtn setBackgroundColor:BTNBACKCOLOR_BLUE];
        _progressView.progressTintColor = color_download_progress_bar;
        _loadinghlengthLabel.textColor = color_download_finshed_label;
        _fileLoadFinshedLabel.textColor = colorWithHexStr(@"#ff3f21");
        _fileLoadFinshedLabel.text = localizedString(@"download_failed");
      //  _downloadBtn.enabled = NO;
    }
    
    if (_item.downloadStatus == CAGDownloadStatusFinished ||
        _item.downloadStatus == CAGDownloadStatusUpdate){
        _progressView.hidden = YES;
        _lengthLabel.hidden = YES;
        _loadinghlengthLabel.hidden = YES;
        _fileNameLabel.frame = _fileNameLabelFinishedRect;
        _downloadBtn.frame = _downloadBtnFinishedRect;
        _fileLoadFinshedLabel.hidden = NO;
    }else if (_item.downloadStatus == CAGDownloadStatusFailure){
        _progressView.hidden = YES;
        _lengthLabel.hidden = YES;
        _loadinghlengthLabel.hidden = YES;
        _fileNameLabel.frame = _fileNameLabelFinishedRect;
        _downloadBtn.frame = _downloadBtnFinishedRect;
        _fileLoadFinshedLabel.hidden = NO;
    }else if (_item.downloadStatus == CAGDownloadStatusDownReady){
        [self setLableText:localizedString(@"download_waitting")];
    }else if (_item.downloadStatus == CAGDownloadStatusPause){
        [self setLableText:localizedString(@"download_isPause")];
    }else{
        _progressView.hidden = NO;
        _lengthLabel.hidden = NO;
        _loadinghlengthLabel.hidden = NO;
        _fileLoadFinshedLabel.hidden = YES;
        _fileNameLabel.frame = _fileNameLabelOriginRect;
        _downloadBtn.frame = _downloadBtnOriginRect;
        
        long long downloadLength = 0;
        long long tmpSize = 0;

        if (_item.size * M_SIZE > (_totalBytesExpectedToRead + _item.downloadLength)){
            if (_totalBytesExpectedToRead > 0){
                tmpSize = _item.size * M_SIZE - _totalBytesExpectedToRead - _item.downloadLength;
            }
        }
        
        if (_item.downloadLength > 0) {
            downloadLength = _item.downloadLength + tmpSize;
        }
        
        _progressView.progress=(float)downloadLength/M_SIZE/(float)_item.size;
        [_progressView setProgress:(float)downloadLength/M_SIZE/(float)_item.size animated:YES];
        
        float downLen = (float)downloadLength/M_SIZE;
        if (downLen > _item.size) {
            downLen = _item.size - 0.1;
        }
        
        _lengthLabel.text = [NSString stringWithFormat:@" / %.2fM",(float)_item.size];
        
        [_loadinghlengthLabel setNumberOfLines:0];
        
        //动态调整下载长度label大小
        NSString *strLoadinghlength = [NSString stringWithFormat:@"%.2fM",downLen];
//        if (_item.downloadStatus == CAGDownloadStatusPause){
//            strLoadinghlength = localizedString(@"download_isPause");
//            _lengthLabel.hidden = YES;
//        }else if (_item.downloadStatus == CAGDownloadStatusDownReady){
//            strLoadinghlength = localizedString(@"download_waitting");
//            _lengthLabel.hidden = YES;
//        }
        
        [self setLoadingLenLabFrame:strLoadinghlength];
    }
}

-(void)setLoadingLenLabFrame:(NSString*)strLoadinghlength{
    
    UIFont *font = _loadinghlengthLabel.font;
    CGSize size = CGSizeMake(200,200);
    
    CGSize labelsize = [self boundingRectTxt:strLoadinghlength font:font maxsize:size];
    
    [_loadinghlengthLabel setFrame:CGRectMake(_loadinghlengthLabel.frame.origin.x, _loadinghlengthLabel.frame.origin.y, labelsize.width, _loadinghlengthLabel.frame.size.height)];
    _loadinghlengthLabel.text = strLoadinghlength;
    
    [_lengthLabel setFrame:CGRectMake(_loadinghlengthLabel.frame.origin.x + _loadinghlengthLabel.frame.size.width, _loadinghlengthLabel.frame.origin.y, _lengthLabel.frame.size.width, _lengthLabel.frame.size.height)];
}

-(void)setLableText:(NSString*)text{
    // 设置已暂停 获取中字样
   // if ((_item.operation.isReady || _item.operation.isExecuting) && _item.downloadStatus != CAGDownloadStatusPause) {
        _progressView.hidden = NO;
        _loadinghlengthLabel.hidden = NO;
        _fileLoadFinshedLabel.hidden = YES;

        _loadinghlengthLabel.text = text;
        [self setLoadingLenLabFrame:text];
        _loadinghlengthLabel.textColor = color_download_finshed_label;
        _lengthLabel.hidden = YES;
        _progressView.progressTintColor = color_download_progress_bar;
  //  }
}

- (void)downloadProgress:(NSUInteger)bytesRead withTotalBytesRead:(long long)totalBytesRead withTotalBytesExpectedToRead:(long long)totalBytesExpectedToRead
{
  //  _item.size = totalBytesExpectedToRead; //临时因为没有size参数
    //_item.downloadLength += bytesRead;下载长度===27.08
    //2015-08-21 16:14:32.887 CavyGame[1740:57746] 文件总大小：27.08
  //  _totalBytesExpectedToRead = totalBytesExpectedToRead;
   // long long tmpSize = 0;
    /*
    if (_item.size * M_SIZE > (totalBytesExpectedToRead + _item.downloadLength)){
        tmpSize = _item.size * M_SIZE - totalBytesExpectedToRead - _item.downloadLength;
    }
    _item.downloadLength = _item.downloadLength + bytesRead + tmpSize;
    float downLen = (float)_item.downloadLength/M_SIZE;*/

    
  //  _item.downloadLength = _downloadLengthInit + totalBytesRead;
  //  NSLog(@"tmpSize===%lld", _item.downloadLength);
  //  NSLog(@"下载长度===%.2f", downLen);
  //  NSLog(@"文件总大小：%.2f", (float) totalBytesExpectedToRead / M_SIZE);
    [self updateView];
}
- (void)downloadCompletionBlockWithSuccess:(AFHTTPRequestOperation *)operation withId:(id)responseObject
{
//    _item.downloadLength = _item.size;
//    _item.downloadStatus = CAGDownloadStatusFinished;
//    [self updateView];
}
- (void)downloadFailure:(AFHTTPRequestOperation *)operation withError:(NSError *)error{
   [self updateView];
}

- (void)downloadProgress:(NSUInteger)bytesRead downLoadItem:(DownloadItem *)item
{
    
}

-(void)downItem{
    if (_item.downloadStatus == CAGDownloadStatusDownloading || _item.downloadStatus == CAGDownloadStatusDownReady){
        
        [[DownloadManager getInstance]downloadBtnClicked:_item];
        
        [_downloadBtn setTitle:localizedString(@"downcontinue") forState:UIControlStateNormal];
        [_downloadBtn setButtonImageStatus:STATUS_Continue];
        [self updateView];
        
        [self doPushNotification:1];
        [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"Pause_%@", _item.gameid] object:nil];
    } else if (_item.downloadStatus == CAGDownloadStatusPause || _item.downloadStatus == CAGDownloadStatusFailure || _item.downloadStatus == CAGDownloadStatusUpdate) {
        
        [self updateView];
        [self setLableText:localizedString(@"download_waitting")];

        [[DownloadManager getInstance]downloadBtnClicked:_item];
        
        [_downloadBtn setTitle:localizedString(@"pause") forState:UIControlStateNormal];
        [_downloadBtn setButtonImageStatus:STATUS_Pause];
        [self doPushNotification:0];
        [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"Downloading_%@", _item.gameid] object:nil];
    }
    else //if (_item.downloadStatus == CAGDownloadStatusFinished)
    {
        [[DownloadManager getInstance]downloadBtnClicked:_item];
    }
}

-(void)downloadBtnClicked
{
  //  NSLog(@"downloadBtnClicked isExecuting:%d",[_item.operation isExecuting]);
  //  NSLog(@"downloadBtnClicked isPaused:%d",[_item.operation isPaused]);
    
    Down_Interface* downInterFace = [Down_Interface getInstance];
    
    if ([downInterFace isNotReachable]) {
        [ProgressHUD showError:localizedString(@"net_err")];
        
        return;
    }
    BOOL isAlertWifi = [[NSUserDefaults standardUserDefaults]boolForKey:SETTING_KEY_DOWNINWIFI];
    
    // 非wifi 并且是下载 继续
    if (isAlertWifi && ![Reachability reachabilityForLocalWiFi] && (_item.downloadStatus == CAGDownloadStatusPause || _item.downloadStatus == CAGDownloadStatusFailure || _item.downloadStatus == CAGDownloadStatusUpdate)) {
        
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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void) doPushNotification:(NSInteger) status
{//status 0 下载 1 暂停 2 成功 3失败
    NSMutableDictionary *dicData = [[NSMutableDictionary alloc] init];
    [dicData setObject:_item.title forKey:@"gamename"];
    [dicData setObject:_item.version forKey:@"version"];
    [dicData setObject:_item.downurl forKey:@"downurl"];
    [dicData setObject:_item.packagename forKey:@"pageName"];
    [dicData setObject:[NSString stringWithFormat:@"%ld", (long)_item.size] forKey:@"filesize"];
    [dicData setObject:_item.icon forKey:@"icon"];
    [dicData setObject:_item.gameid forKey:@"gameid"];
    [dicData setObject:[NSString stringWithFormat:@"%ld", (long)status] forKey:@"downloadStatus"];
    [dicData setObject:[NSString stringWithFormat:@"%ld", (long)_item.downloadLength] forKey:@"downloadLength"];
    [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"%@", _item.gameid] object:dicData];
    dicData = nil;
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
