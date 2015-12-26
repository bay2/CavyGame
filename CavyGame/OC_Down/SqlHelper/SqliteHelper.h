//
//  SqliteHelper.h
//  goplay
//
//  Created by  on 14-12-13.
//  Copyright (c) 2014年 goplay. All rights reserved.
//

#ifndef goplay_SqliteHelper_h
#define goplay_SqliteHelper_h

#import <sqlite3.h>
#import "FMDatabase.h"

@interface SqliteHelper : NSObject{
    FMDatabase *db;
}
+ (SqliteHelper *)sharedInstance;
-(void) createTableNoidUnique:(id) obj;
-(NSMutableArray *)queryDataIn:(Class)cls withSql:(NSString *)sql withArray:(NSArray *)arr;
- (BOOL)executeUpdate:(NSString*)sql;
-(bool) insert:(id)entity;
- (FMResultSet *)executeQuery:(NSString*)sql;
@end

#endif
