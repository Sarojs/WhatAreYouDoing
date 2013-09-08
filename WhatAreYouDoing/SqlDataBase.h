
#import <sqlite3.h>

/********************************************************************************************************************
 * FoodFacts		: SqlDataBase
 * Abstract		: This class will perform the All operations regarding to the Database. Queries were written in this Class.
 * Author			: Namit Nayak @ Diaspark Inc.
 * Date			: 16 January 2011
 *********************************************************************************************************************/
@interface SqlDataBase : NSObject 

{
@private
	sqlite3				*m_pDataBase;
	sqlite3_stmt		*m_pSqlStatement;	
}
-(void) openDataBase;
-(void) closeDataBase;

// database
-(NSArray*) getAllLogs;
-(NSArray*) getLogsFrom:(NSDate*)fromDate to:(NSDate*)toDate;

-(BOOL)addLogsForDate:(NSDate*)logDate Description:(NSString*)desc withInterval:(NSInteger)interval;

-(BOOL)removeAllLogs;

-(NSString *) getHomedirectoryPath;

@end

