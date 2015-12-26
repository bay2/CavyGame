//
//  EUtils.m
//  CloudDisk
//
//  Created by York on 13-11-30.
//  Copyright (c) 2013年 SAE. All rights reserved.
//

#import "EUtils.h"
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>
#import "Constants.h"

#define DegreesToRadians(x) ((x) * M_PI / 180.0)

@implementation EUtils



+(NSString *)getDocumentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
    
}


+(void)checkAndMakeLocalDirectory:(NSString *)path
{
    BOOL result;
    NSFileManager *fileManger = [NSFileManager defaultManager];
    BOOL exist = [fileManger fileExistsAtPath:path isDirectory:&result];
    NSError *error;
    
    if (exist && !result) {
        [fileManger removeItemAtPath:path error:&error];
    }
    
    if (!exist) {
        [fileManger createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
    }
}



+(NSString *)localizedShortDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    // [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    dateFormatter.timeStyle = kCFDateFormatterNoStyle;
    dateFormatter.dateStyle =  kCFDateFormatterShortStyle;
    return [dateFormatter stringFromDate:date];
}

+(NSString *)localizedFullDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    // [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    dateFormatter.timeStyle = kCFDateFormatterShortStyle;
    dateFormatter.dateStyle =  kCFDateFormatterShortStyle;
    return [dateFormatter stringFromDate:date];
}


+(void)writeDataToFile:(NSString *)file withData:(NSData *)data
{
    BOOL result;
    NSFileManager *fileManger = [NSFileManager defaultManager];
    BOOL exist = [fileManger fileExistsAtPath:file isDirectory:&result];
//    NSError *error;
    
//    if (exist && !result) {
//        [fileManger removeItemAtPath:file error:&error];
//    }
    
    if (!exist) {
        [fileManger createFileAtPath:file contents:nil attributes:nil];
    }
    
    NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:file];
    [handle seekToEndOfFile];
    [handle writeData:data];
    [handle closeFile];
    
//    FILE *f = fopen([file UTF8String], [@"ab+" UTF8String]);
//    
//    if(f != NULL){
//        fseek(f, 0, SEEK_END);
//    }
//    int readSize = [data length];
//    fwrite((const void *)[data bytes], readSize, 1, f);
//    fclose(f);

}


+(long long)getFileLength:(NSString *)file
{
    NSDictionary *attr =[[NSFileManager defaultManager] attributesOfItemAtPath:file error:nil] ; //文件属性
    return [[attr objectForKey:NSFileSize] longLongValue];
}

+(UIColor *)colorWithHexString:(NSString *)stringToConvert
{
    NSString *cString = [[stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return [UIColor grayColor];
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

+(void)setNavigationStyle:(UINavigationController *)nav
{
    //设置导航controller背景图片 iOS7不建议再设置图片,所以这里改用纯色内容
    //设置导航controller颜色，会影响按钮或字体颜色
    nav.navigationBar.tintColor=color_button_text;
    //设置导航controller颜色，会影响背景颜色
    nav.navigationBar.backgroundColor=color_app_head_title_bg;
    
    if (CAG_ios7) {
        //如果要手动设置[navigationBar setBarTintColor:color]
        //这个需要先设置[navigationBar setTranslucent:NO],才能生效
        nav.navigationBar.translucent=NO;
        nav.navigationBar.barTintColor=color_app_head_title_bg;
        //这个属性属于UIExtendedEdge类型，它可以单独指定矩形的四条边，也可以单独指定、指定全部、全部不指定。
        //使用edgesForExtendedLayout指定视图的哪条边需要扩展，不用理会操作栏的透明度。这个属性的默认值是UIRectEdgeAll。
        //这个对于xib创建的view有效，代码无效
        nav.edgesForExtendedLayout = UIRectEdgeNone;
        //如果你使用了不透明的操作栏，设置edgesForExtendedLayout的时候也请将 extendedLayoutIncludesOpaqueBars的值设置为No（默认值是YES）
        nav.extendedLayoutIncludesOpaqueBars = NO;
        nav.modalPresentationCapturesStatusBarAppearance = NO;
        //如果你不想让scroll view的内容自动调整，将这个属性设为NO（默认值YES）。
        nav.automaticallyAdjustsScrollViewInsets=NO;
    }
}


+(BOOL)checkFileName:(NSString *)oldName
{
    NSString *regex=@"^[^\\/\\<>\\*\?\\:\"\\|.#]{1,16}";
    NSPredicate *nameTest=[NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    BOOL result= [nameTest evaluateWithObject:oldName];
    return result;
}

+(BOOL)checkFolderName:(NSString *)oldName
{
    NSString *regex=@"^[^\\/\\<>\\*\?\\:\"\\|.#]{1,16}";
    NSPredicate *nameTest=[NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    BOOL result= [nameTest evaluateWithObject:oldName];
    return result;
}


@end
