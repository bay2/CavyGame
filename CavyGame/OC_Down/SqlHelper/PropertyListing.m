//
//  PropertyListing.m
//  CavyGame
//
//  Created by on 14-12-13.
//  Copyright (c) 2014年 goplay. All rights reserved.
//
#import <objc/runtime.h>
#import <objc/NSObject.h>
#import <Foundation/Foundation.h>

@implementation NSObject (PropertyListing)
const char numericEncodings[] = {
    'c',
    'i',
    's',
    'l',
    'q',
    'C',
    'I',
    'S',
    'L',
    'Q',
    'f',
    'd',
};
const size_t sizeEncodings[] = {
    sizeof(char),
    sizeof(int),
    sizeof(short),
    sizeof(long),
    sizeof(long long),
    sizeof(unsigned char),
    sizeof(unsigned int),
    sizeof(unsigned short),
    sizeof(unsigned long),
    sizeof(unsigned long long),
    sizeof(float),
    sizeof(double),
};
/* 获取对象的所有属性 */
- (NSDictionary *)properties_aps
{
    NSMutableDictionary *props = [NSMutableDictionary dictionary];
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);

    for (i = 0; i<outCount; i++)
    {
        objc_property_t property = properties[i];
        const char* char_f =property_getName(property);
        NSString *propertyName = [NSString stringWithUTF8String:char_f];
        id propertyValue = [self valueForKey:(NSString *)propertyName];

        id value=propertyValue;
        if([value isKindOfClass:[NSNumber class]])
        {
            [props setObject:propertyValue forKey:propertyName];
        }else if([value isKindOfClass:[NSString class]]){
            [props setObject:propertyValue forKey:propertyName];
        }else if([value isKindOfClass:[NSData class]]){
            [props setObject:propertyValue forKey:propertyName];
        }else if(!value){
        }
    }
    free(properties);
    return props;
}
/* 获取对象的所有属性 */
- (NSDictionary *)properties_types
{
    NSMutableDictionary *props = [NSMutableDictionary dictionary];
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    for (i = 0; i<outCount; i++)
    {
        objc_property_t property = properties[i];
        const char* char_f =property_getName(property);
        NSString *propertyName = [NSString stringWithUTF8String:char_f];
        id propertyValue = [self valueForKey:(NSString *)propertyName];
        
        if([propertyValue isKindOfClass:[NSNumber class]])
        {
            NSString *type;
            
            if (strcmp([propertyValue objCType], @encode(float)) == 0)
            {
                type=@"float";
            }
            else if (strcmp([propertyValue objCType], @encode(double)) == 0)
            {
                type=@"double";
            }
            else if (strcmp([propertyValue objCType], @encode(long long)) == 0)
            {
                type=@"long";
            }
            else if (strcmp([propertyValue objCType], @encode(int)) == 0)
            {
                type=@"int";
            }
            else if (strcmp([propertyValue objCType], "c") == 0)
            {
                type=@"bit";
            }
            else{
                
            }
            [props setObject:type forKey:propertyName];
        }else if([propertyValue isKindOfClass:[NSString class]]){
            [props setObject:@"text" forKey:propertyName];
        }else if([propertyValue isKindOfClass:[NSData class]]){
            [props setObject:@"blob" forKey:propertyName];
        }else if(!propertyValue){
        }
    }
    free(properties);
    return props;
}/* 获取对象的所有方法 */
-(void)printMothList
{
    unsigned int mothCout_f =0;
    Method* mothList_f = class_copyMethodList([self class],&mothCout_f);
    for(int i=0;i<mothCout_f;i++)
    {
        Method temp_f = mothList_f[i];

        const char* name_s =sel_getName(method_getName(temp_f));
        int arguments = method_getNumberOfArguments(temp_f);
        const char* encoding =method_getTypeEncoding(temp_f);
        
        NSLog(@"方法名：%@,参数个数：%d,编码方式：%@",[NSString stringWithUTF8String:name_s],
              arguments,
              [NSString stringWithUTF8String:encoding]);
    }
    free(mothList_f);
}


@end