//
//  DownloadItem.h
//  CavyGame
//
//  Created by York on 7/7/15.
//  Copyright (c) 2015 York. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "AFDownloadRequestOperation.h"

#define DEFAULT_STRING @""

typedef NS_ENUM(NSInteger, CAGDownloadStatus) {
    CAGDownloadStatusDownReady,
    CAGDownloadStatusDownloading,
    CAGDownloadStatusPause,
    CAGDownloadStatusFinished,
    CAGDownloadStatusFailure,
    CAGDownloadStatusUpdate,
    CAGDownloadDeleting
};

@class DownloadItem;
@protocol DownloadDelegate <NSObject>

@optional
- (void)downloadProgress:(NSUInteger)bytesRead withTotalBytesRead:(long long)totalBytesRead withTotalBytesExpectedToRead:(long long)totalBytesExpectedToRead;
- (void)downloadCompletionBlockWithSuccess:(AFHTTPRequestOperation *)operation withId:(id)responseObject;
- (void)downloadFailure:(AFHTTPRequestOperation *)operation withError:(NSError *)error;
//- (void) downloadProgress:(NSUInteger) bytesRead downLoadItem:(DownloadItem *) item;
@end

@interface DownloadItem : NSObject


@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSString *version;
@property (nonatomic,strong) NSString *downurl;
@property (nonatomic,strong) NSString *plisturl;
@property (nonatomic,strong) NSString *packagename;
@property (nonatomic) NSInteger size;
@property (nonatomic,strong) NSString *icon;
@property (nonatomic,strong) NSString *gameid;

@property (nonatomic) long long downloadLength;
@property (nonatomic) CAGDownloadStatus downloadStatus;
@property (nonatomic,strong) NSString *localFile;
@property (nonatomic,strong) AFDownloadRequestOperation *operation;
@property (nonatomic,strong) id<DownloadDelegate> delegate;
@property (nonatomic) BOOL isCheckUpdate;  // 是否已经检查过更新

@property (nonatomic) NSInteger stdForSql;

- (id)init;
- (void)downloadProgress:(NSUInteger)bytesRead withTotalBytesRead:(long long)totalBytesRead withTotalBytesExpectedToRead:(long long)totalBytesExpectedToRead;
- (void)downloadCompletionBlockWithSuccess:(AFHTTPRequestOperation *)operation withId:(id)responseObject;
- (void)downloadFailure:(AFHTTPRequestOperation *)operation withError:(NSError *)error;

@end



