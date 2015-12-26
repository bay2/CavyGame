//
//  EUtils.h
//  CloudDisk
//
//  Created by York on 13-11-30.
//  Copyright (c) 2013年 SAE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface EUtils : NSObject

+(NSString *)getDocumentsDirectory;
+(void)checkLocalDocumentsDirectory;
+(void)checkAndMakeLocalDirectory:(NSString *)path;
+(NSMutableArray *)ItemsOfDirectoryAtPath:(NSString *)path;
+(NSString *)localizedFullDate:(NSDate *)date;
+(NSString *)localizedShortDate:(NSDate *)date;



+(void)writeDataToFile:(NSString *)file withData:(NSData *)data;
+(NSArray *)sortItemContentArray:(NSArray *)contents;
+(long long)getFileLength:(NSString *)file;


+(UIColor *)colorWithHexString:(NSString *)stringToConvert;
+(void)setNavigationStyle:(UINavigationController *)nav;

@end
