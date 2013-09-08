//
//  DataBase.h
//  TestFoodFacts
//
//  Created by mac12 on 19/01/11.
//  Copyright 2011 Diaspark India. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SqlDataBase.h"

@interface DataBaseInterface : NSObject {

}

// Flower database
+(void)openDataBase;
+(NSArray*) getAllLogs;
+(NSArray*) getLogsFrom:(NSDate*)fromDate to:(NSDate*)toDate;
+(BOOL)addLogsForDate:(NSDate*)logDate Description:(NSString*)desc withInterval:(NSInteger)interval;

+(BOOL)removeAllLogs;

@end
