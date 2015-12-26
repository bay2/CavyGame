//
//  SqliteHelper.m
//
//
//  Created by  on 14-12-13.
//  Copyright (c) 2014年 goplay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "SqliteHelper.h"
#import "FMDatabase.h"
#import "FMResultSet.h"
#import "PropertyListing.h"
#import "DownloadItem.h"
#import "FMDatabaseAdditions.h"

@implementation SqliteHelper

+(SqliteHelper *) sharedInstance
{
    static SqliteHelper *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    if(!sharedInstance->db){
        NSString *database_path = [sharedInstance getPath];
        sharedInstance->db = [FMDatabase databaseWithPath:database_path];
        if (![sharedInstance->db open]){
            NSLog(@"OPEN FAIL");
            return nil;
        }
    }
    return sharedInstance;
}

-(void)resetDB
{
    self->db=nil;
}

-(bool) update:(id)entity{

        [db beginTransaction];
        [self updateIn:entity];
        [db commit];
        return true;
}
-(void) createTable:(id) act{
    //NSMutableString *sb = [NSMutableString stringWithString:@"CREATE TABLE IF NOT EXISTS "];
    NSMutableString *sb = [NSMutableString stringWithString:@"CREATE TABLE IF NOT EXISTS "];
    [sb appendString:[NSString stringWithUTF8String:object_getClassName(act)]];    //
    [sb appendString:@"("];
    NSDictionary *pers=[act properties_types];
    NSArray *keys;
    int i, count;
    id key, value;
    
    keys = [pers allKeys];
    count = (int)[keys count];
    for (i = 0; i < count; i++)
    {
        key = [keys objectAtIndex: i];
        if(i==0){
            [sb appendString:key];
        }else{
            [sb appendString:@","];
            [sb appendString:key];
        }
        [sb appendString:@" "];
        value = [pers objectForKey: key];
        [sb appendString:value];
        if([key isEqual:@"id"]){
            [sb appendString:@" unique"];
        }
    }
    [sb appendString:@")"];
    [db executeUpdate:sb];
}

//- (BOOL) isTableOK
//{
//    FMResultSet *rs = [self executeQuery:@"select count(*) as 'count' from sqlite_master where type ='table' and name = 'DownloadItem'"];
//    while ([rs next])
//    {
//        // just print out what we've got in a number of formats.
//        NSInteger count = [rs intForColumn:@"count"];
//        NSLog(@"isTableOK %d", count);
//        
//        if (0 == count)
//        {
//            return NO;
//        }
//        else
//        {
//            return YES;
//        }
//    }
//    
//    
//    return NO;
//}

// 删除表
- (BOOL) deleteTable:(NSString *)tableName
{
    NSString *sqlstr = [NSString stringWithFormat:@"DROP TABLE %@", tableName];
    if (![db executeUpdate:sqlstr])
    {
        return NO;
    }
    
    return YES;
}

-(void) createTableNoidUnique:(id) obj{
    //NSMutableString *sb = [NSMutableString stringWithString:@"CREATE TABLE IF NOT EXISTS "];
    NSMutableString *sb = [NSMutableString stringWithString:@"CREATE TABLE IF NOT EXISTS "];
    [sb appendString:[NSString stringWithUTF8String:object_getClassName(obj)]];
    //
    [sb appendString:@"("];
    NSDictionary *pers=[obj properties_types];
    NSArray *keys;
    int i, count;
    id key, value;
    
    keys = [pers allKeys];
    count = (int)[keys count];
    for (i = 0; i < count; i++)
    {
        key = [keys objectAtIndex: i];
        if(i==0){
            [sb appendString:key];
        }else{
            [sb appendString:@","];
            [sb appendString:key];
        }
        [sb appendString:@" "];
        value = [pers objectForKey: key];
        [sb appendString:value];
    }
    [sb appendString:@")"];
    
    if (YES == [db tableExists:@"DownloadItem"]) {
        
        for (i = 0; i < count; i++)
        {
            key = [keys objectAtIndex: i];
            if(i!=0){
                
                if (NO == [db columnExists:key inTableWithName:@"DownloadItem"]) {
                    
                    [self deleteTable:@"DownloadItem"];
                    break;
                    
                }
            }
            
        }
    }
    
    BOOL result = [db executeUpdate:sb];
    
    if (result == NO) {
        NSLog(@"CREATE TALBE FAILD");
    }
    

    
    
}
-(void) updateIn:(id) act{
    NSMutableString *sb = [NSMutableString stringWithString:@"update "];
    [sb appendString:[NSString stringWithUTF8String:object_getClassName(act)]];
    //
    [sb appendString:@" set "];
    NSDictionary *pers=[act properties_aps];
    NSArray *keys;
    int i, count;
    id key, value;
    
    keys = [pers allKeys];
    count = (int)[keys count];
    NSMutableArray *arr=[NSMutableArray arrayWithCapacity:count+1];
    //[NS g
    for (i = 0; i < count; i++)
    {
        key = [keys objectAtIndex: i];
        if(i==0){
            [sb appendString:key];
        }else{
            [sb appendString:@","];
            [sb appendString:key];
        }
        [sb appendString:@"=?"];
    }
    [sb appendString:@" where id=?"];
    id cc;
    for (i = 0; i < count; i++)
    {
        key = [keys objectAtIndex: i];
        value = [pers objectForKey: key];
        [arr addObject:value];
        if([key isEqual:@"id"]){
            cc=value;
        }
    }
    [arr addObject:cc];//[NSString
    [db executeUpdate:sb withArgumentsInArray:arr];
}
-(void) updateIn:(id) act withQuery:(NSString *)query{
    NSMutableString *sb = [NSMutableString stringWithString:@"update "];
    [sb appendString:[NSString stringWithUTF8String:object_getClassName(act)]];
    //
    [sb appendString:@" set "];
    NSDictionary *pers=[act properties_aps];
    NSArray *keys;
    int i, count;
    id key, value;
    
    keys = [pers allKeys];
    count = (int)[keys count];
    NSMutableArray *arr=[NSMutableArray arrayWithCapacity:count+1];
    //[NS g
    for (i = 0; i < count; i++)
    {
        key = [keys objectAtIndex: i];
        if(i==0){
            [sb appendString:key];
        }else{
            [sb appendString:@","];
            [sb appendString:key];
        }
        [sb appendString:@"=?"];
    }
    [sb appendString:@" "];
    [sb appendString:query];
    for (i = 0; i < count; i++)
    {
        key = [keys objectAtIndex: i];
        value = [pers objectForKey: key];
        [arr addObject:value];
    }
    [db executeUpdate:sb withArgumentsInArray:arr];
}

- (BOOL)executeUpdate:(NSString*)sql{
    
    [db beginTransaction];
    BOOL result = [db executeUpdate:sql];

    if (result == false) {
        NSLog(@"update faild");
    }
    [db commit];

    return result;
}

-(bool) insert:(id)entity{
    [db beginTransaction];
    [self insertIn:entity];
    [db commit];
    return true;
}

-(void) insertIn:(id) act{
    NSMutableString *sb = [NSMutableString stringWithString:@"INSERT INTO "];
    [sb appendString:[NSString stringWithUTF8String:object_getClassName(act)]];
    //
    [sb appendString:@"("];
    NSDictionary *pers=[act properties_aps];
    NSArray *keys;
    int i, count;
    id key, value;
    
    keys = [pers allKeys];
    count = (int)[keys count];
    NSMutableArray *arr=[NSMutableArray arrayWithCapacity:count];
    //[NS g
    for (i = 0; i < count; i++)
    {
        key = [keys objectAtIndex: i];
        if(i==0){
            [sb appendString:key];
        }else{
            [sb appendString:@","];
            [sb appendString:key];
        }
    }
    [sb appendString:@") values("];
    for (i = 0; i < count; i++)
    {
        key = [keys objectAtIndex: i];
        value = [pers objectForKey: key];
        [arr addObject:value];
        [sb appendString:@"?"];
        if(i!=count-1){
            [sb appendString:@","];
        }
    }
    [sb appendString:@")"];
    BOOL ret = [db executeUpdate:sb withArgumentsInArray:arr];
    
    if (ret == NO) {
        NSLog(@"insert faild");
    }
}

- (FMResultSet *)executeQuery:(NSString*)sql{
    
    return [db executeQuery:sql];
}


-(NSMutableArray *)queryDataIn:(Class)cls withSql:(NSString *)sql withArray:(NSArray *)arr{
    NSMutableArray *recordArray =[[NSMutableArray alloc] init];
    FMResultSet *rs;
    if(arr!=nil){
        rs = [db executeQuery:sql withArgumentsInArray:arr];
    }else{
        rs = [db executeQuery:sql];
    }
    while ([rs next]){
        id act=[[DownloadItem alloc] init];
        NSDictionary *pers=[act properties_types];
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
                [act setValue:[rs stringForColumn:key] forKey:key];
            }
            else if([value isEqualToString:@"blob"]){
                [act setValue:[rs dataForColumn:key] forKey:key];
            }
            else if([value isEqualToString:@"bit"]){
                NSNumber* b=[NSNumber numberWithInt:([rs boolForColumn:key]?1:0)];
                [act setValue:b forKey:key];
            }
            else if([value isEqualToString:@"int"]){
                NSNumber* b=[NSNumber numberWithInt:[rs intForColumn:key]];
                [act setValue:b forKey:key];
            }
            else if([value isEqualToString:@"float"]){
                NSNumber* b=[NSNumber numberWithFloat:[rs doubleForColumn:key]];
                [act setValue:b forKey:key];
            }
            else if([value isEqualToString:@"double"]){
                NSNumber* b=[NSNumber numberWithDouble:[rs doubleForColumn:key]];
                [act setValue:b forKey:key];
            }
            else if([value isEqualToString:@"long"]){
                NSNumber* b=[NSNumber numberWithLongLong:[rs longLongIntForColumn:key]];
                [act setValue:b forKey:key];
            }
        }
        [recordArray addObject:act];
    }
    [rs close];
    return recordArray;
}


- (NSString*) getPath {

    NSArray* paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) ;
    return [[paths objectAtIndex:0] stringByAppendingPathComponent:@"dbcash.sqlite"] ;
}

-(void) clearTableData:(id) act{
    NSMutableString *sb = [NSMutableString stringWithString:@"DELETE FROM "];
    [sb appendString:[NSString stringWithUTF8String:object_getClassName(act)]];
    
    [db executeUpdate:sb];
}

@end