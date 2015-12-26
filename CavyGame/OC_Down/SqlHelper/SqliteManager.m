//
//  SqliteManager.m
//  CavyGame
//
//  Created by longjining on 15/7/20.
//  Copyright (c) 2015年 York. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SqliteManager.h"
#import "DownloadItem.h"
#import "PropertyListing.h"

#define DocumentsDirectory [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) lastObject]

@implementation SqliteManager

+(SqliteManager *) sharedInstance
{
    static SqliteManager *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });

    return sharedInstance;
}

-(NSMutableArray *)queryData:(id)entity withSql:(NSString *)sql withArray:(NSArray *)array
{
    //获取数据
    
    NSMutableArray *recordArray = [[SqliteHelper sharedInstance] queryDataIn:entity withSql:sql withArray:array];

    return recordArray;
}

-(NSMutableArray *)queryDownData:(id)entity withSta:(int)std
{
    NSString* tablName = [NSString stringWithUTF8String:object_getClassName(entity)];
    
    NSString* querySql = [[NSString alloc] initWithFormat:@"select * from %@ where stdForSql='%d'", tablName, std];

    NSMutableArray *recordArray = [[SqliteHelper sharedInstance] queryDataIn:entity withSql:querySql withArray:nil];
    
    return recordArray;
}

-(void)initDowningData{
    
    NSString* querySql = [[NSString alloc] initWithFormat:@"update DownloadItem set stdForSql='%d' where stdForSql='%d'", DOWNSTD_PAUSE, DOWNSTD_DOWNING];
    
     [[SqliteHelper sharedInstance] executeUpdate:querySql];
}

-(bool) insert:(id)entity
{
    DownloadItem* act=entity;
    NSMutableString *sb = [NSMutableString stringWithString:@"SELECT * from "];
    [sb appendString:[NSString stringWithUTF8String:object_getClassName(act)]];
    [sb appendString:@" where gameid='"];
    [sb appendString:act.gameid];
    [sb appendString:@"'"];
    
    FMResultSet *rs = [[SqliteHelper sharedInstance] executeQuery:sb];
    if([rs next]){
        [rs close];
        return [self updata:act.gameid withstd:act.stdForSql];
    }else{
        return [[SqliteHelper sharedInstance] insert:entity];
    }
}

-(bool) deleteData:(NSString*)gameid
{
    
    NSString* deleteSql = [[NSString alloc] initWithFormat:@"delete from DownloadItem where gameid='%@'", gameid];
    
    return [[SqliteHelper sharedInstance] executeUpdate:deleteSql];
}

-(bool) updata:(NSString*)gameid withstd:(long)std
{
    NSString* querySql = [[NSString alloc] initWithFormat:@"update DownloadItem set stdForSql='%ld' where gameid='%@'", std, gameid];
    
    return [[SqliteHelper sharedInstance] executeUpdate:querySql];
}

-(bool) updata:(NSString*)gameid withplist:(NSString*)plist
{
    NSString* querySql = [[NSString alloc] initWithFormat:@"update DownloadItem set plisturl='%@' where gameid='%@'", plist, gameid];
    
    return [[SqliteHelper sharedInstance] executeUpdate:querySql];
}

-(bool) querydata:(NSString*)gameid withstd:(long)std
{
    
    NSString* querySql;
    
    if (-1 == std) {
        querySql = [[NSString alloc] initWithFormat:@"select * from DownloadItem where gameid='%@'", gameid];
    }else{
        querySql = [[NSString alloc] initWithFormat:@"select * from DownloadItem where gameid='%@' and stdForSql='%ld'", gameid, std];
    }
    
    FMResultSet *rs = [[SqliteHelper sharedInstance] executeQuery:querySql];
    
    if (rs == nil) {
        return false;
    }
    if([rs next]){
        [rs close];
        return true;
    }else{
        [rs close];
        return false;
    }
}

-(bool) updata:(NSString*)gameid withstd:(long)std  withDownStd:(int)downstd version:(int)versionNew
{
    NSString* querySql = [[NSString alloc] initWithFormat:@"update DownloadItem set stdForSql='%ld',downloadStatus='%d', version=%d where gameid='%@'", std, downstd, versionNew, gameid];
    
    return [[SqliteHelper sharedInstance] executeUpdate:querySql];
}

- (DownloadItem *) queryGameStd:(NSString *) gameid
{
    //NSString *stdForSql = @"-1";
    NSString* querySql = [[NSString alloc] initWithFormat:@"select * from DownloadItem where gameid='%@'", gameid];
    FMResultSet *rs = [[SqliteHelper sharedInstance] executeQuery:querySql];
    DownloadItem *item = nil;
    while ([rs next]) {
        item = [[DownloadItem alloc] init];
        NSDictionary *pers=[item properties_types];
        NSArray *keys;
        int i, count;
        id key, value;
        
        keys = [pers allKeys];
        count = (int)[keys count];
        for (i = 0; i < count; i++)
        {
            key = [keys objectAtIndex: i];
            value = [pers objectForKey: key];
            if([value isEqualToString:@"text"]){
                [item setValue:[rs stringForColumn:key] forKey:key];
            }
            else if([value isEqualToString:@"blob"]){
                [item setValue:[rs dataForColumn:key] forKey:key];
            }
            else if([value isEqualToString:@"bit"]){
                NSNumber* b=[NSNumber numberWithInt:([rs boolForColumn:key]?1:0)];
                [item setValue:b forKey:key];
            }
            else if([value isEqualToString:@"int"]){
                NSNumber* b=[NSNumber numberWithInt:[rs intForColumn:key]];
                [item setValue:b forKey:key];
            }
            else if([value isEqualToString:@"float"]){
                NSNumber* b=[NSNumber numberWithFloat:[rs doubleForColumn:key]];
                [item setValue:b forKey:key];
            }
            else if([value isEqualToString:@"double"]){
                NSNumber* b=[NSNumber numberWithDouble:[rs doubleForColumn:key]];
                [item setValue:b forKey:key];
            }
            else if([value isEqualToString:@"long"]){
                NSNumber* b=[NSNumber numberWithLongLong:[rs longLongIntForColumn:key]];
                [item setValue:b forKey:key];
            }
        }
        //stdForSql = [rs stringForColumn:@"stdForSql"];
    }
    [rs close];
    
    NSString *filename = [item.downurl lastPathComponent];
    NSString *filePath = [DocumentsDirectory stringByAppendingPathComponent:filename];
    item.downloadLength = [self fileSizeForPath:filePath];
    
    return item;
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

- (DownloadItem *) queryGameItem:(NSString *) gameid
{
    DownloadItem *downItem = nil;
    
    return downItem;
}

@end