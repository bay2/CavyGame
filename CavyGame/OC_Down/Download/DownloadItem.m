//
//  DownloadItem.m
//  CavyGame
//
//  Created by York on 7/7/15.
//  Copyright (c) 2015 York. All rights reserved.
//

#import "DownloadItem.h"
#import "Constants.h"

#define DocumentsDirectory [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) lastObject]

@implementation DownloadItem

- (id)init {
    self = [super init];  // Call a designated initializer here.
    if (self != nil) {

        self.downloadLength = 0;
        self.title = DEFAULT_STRING;
        self.version = DEFAULT_STRING;
        self.downurl = DEFAULT_STRING;
        self.packagename = DEFAULT_STRING;
        self.icon = DEFAULT_STRING;
        self.gameid = DEFAULT_STRING;
        self.localFile = DEFAULT_STRING;
        self.plisturl = DEFAULT_STRING;
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

- (void)downloadProgress:(NSUInteger)bytesRead withTotalBytesRead:(long long)totalBytesRead withTotalBytesExpectedToRead:(long long)totalBytesExpectedToRead
{
    //NSString *filename = [self.downurl lastPathComponent];
    //NSString *filePath = [DocumentsDirectory stringByAppendingPathComponent:filename];
    
    if (self.downloadStatus == CAGDownloadStatusDownReady) {
        self.downloadStatus = CAGDownloadStatusDownloading;
    }
    
    long long tmpSize = 0;
    if (self.size * M_SIZE > (totalBytesExpectedToRead + self.downloadLength)){
        tmpSize = self.size * M_SIZE - totalBytesExpectedToRead - self.downloadLength;
    }
    self.downloadLength = self.downloadLength + bytesRead;
 
    long long progressLenght = self.downloadLength + tmpSize;

    NSMutableDictionary *dicData = [[NSMutableDictionary alloc] init];
    [dicData setObject:self.title forKey:@"gamename"];
    [dicData setObject:self.version forKey:@"version"];
    [dicData setObject:self.downurl forKey:@"downurl"];
    [dicData setObject:self.packagename forKey:@"pageName"];
    [dicData setObject:[NSString stringWithFormat:@"%ld", (long)self.size] forKey:@"filesize"];
    [dicData setObject:self.icon forKey:@"icon"];
    [dicData setObject:self.gameid forKey:@"gameid"];
    [dicData setObject:@"1" forKey:@"downloadStatus"];//下载
    [dicData setObject:[NSString stringWithFormat:@"%lld", progressLenght] forKey:@"downloadLength"];
    
    if (self.downloadStatus != CAGDownloadStatusPause) {
        [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithString:self.gameid] object:dicData];
    }

    dicData = nil;

    
    if (self.delegate) {
        [self.delegate downloadProgress:bytesRead withTotalBytesRead:totalBytesRead withTotalBytesExpectedToRead:totalBytesExpectedToRead];
    }
}
- (void)downloadCompletionBlockWithSuccess:(AFHTTPRequestOperation *)operation withId:(id)responseObject
{
    if (self.delegate) {
        [self.delegate downloadCompletionBlockWithSuccess:operation withId:responseObject];
    }
}
- (void)downloadFailure:(AFHTTPRequestOperation *)operation withError:(NSError *)error{
    NSString *filename = [self.downurl lastPathComponent];
    NSString *filePath = [DocumentsDirectory stringByAppendingPathComponent:filename];
    long long progressLenght = [self fileSizeForPath:filePath];
    
    NSMutableDictionary *dicData = [[NSMutableDictionary alloc] init];
    [dicData setObject:self.title forKey:@"gamename"];
    [dicData setObject:self.version forKey:@"version"];
    [dicData setObject:self.downurl forKey:@"downurl"];
    [dicData setObject:self.packagename forKey:@"pageName"];
    [dicData setObject:[NSString stringWithFormat:@"%ld", (long)self.size] forKey:@"filesize"];
    [dicData setObject:self.icon forKey:@"icon"];
    [dicData setObject:self.gameid forKey:@"gameid"];
    [dicData setObject:@"4" forKey:@"downloadStatus"];//失败
    [dicData setObject:[NSString stringWithFormat:@"%lld", progressLenght] forKey:@"downloadLength"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"%@", self.gameid] object:dicData];
    dicData = nil;
    
    if (self.delegate) {
        [self.delegate downloadFailure:operation withError:error];
    }
}

@end
