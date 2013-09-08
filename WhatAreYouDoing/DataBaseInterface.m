//
//  DataBase.m
//  TestFoodFacts
//
//  Created by mac12 on 19/01/11.
//  Copyright 2011 Diaspark India. All rights reserved.
//

#import "DataBaseInterface.h"


@implementation DataBaseInterface
#pragma mark -
#pragma mark GETDATA  METHOD

+(void)openDataBase{
	SqlDataBase *dataBase = [[SqlDataBase alloc]init];
	[dataBase openDataBase];
	[dataBase release];
}

+(void)closeDataBase{
	SqlDataBase *dataBase = [[SqlDataBase alloc]init];
	[dataBase closeDataBase];
	[dataBase release];
}

+(NSArray*) getAllLogs{
    SqlDataBase *dataBase = [[SqlDataBase alloc]init];
	
	NSArray *arrLogs =  [[dataBase getAllLogs] retain];
	
	[dataBase release];
	
	return [arrLogs autorelease];
}

+(NSArray*) getLogsFrom:(NSDate*)fromDate to:(NSDate*)toDate{
    SqlDataBase *dataBase = [[SqlDataBase alloc]init];
	
	NSArray *arrLogs =  [[dataBase getLogsFrom:fromDate to:toDate] retain];
	
	[dataBase release];
	
	return [arrLogs autorelease];
}

+(BOOL)addLogsForDate:(NSDate*)logDate Description:(NSString*)desc withInterval:(NSInteger)interval{

    SqlDataBase *dataBase = [[SqlDataBase alloc]init];
	
	BOOL isSuccess= [dataBase addLogsForDate:logDate Description:desc withInterval:interval];
	
	[dataBase release];
    
    return isSuccess;
}

+(BOOL)removeAllLogs{
    SqlDataBase *dataBase = [[SqlDataBase alloc]init];
	
	BOOL issuccess=[dataBase removeAllLogs];
	
	[dataBase release];
    return issuccess;
}

@end
