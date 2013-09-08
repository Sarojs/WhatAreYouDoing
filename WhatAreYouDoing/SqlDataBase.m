
#import "SqlDataBase.h"

#import "LogFile.h"

//#define FOODFACTS_DATABASE_FILE @"Person"
#define FOODFACTS_DATABASE_FILE @"WhatAreYouDoing"

// Table name is PersonTable

@implementation SqlDataBase
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//@Method		: openDataBase
//@Abstract		: This method is responsible for connection Open of Sqlite Database.
//@Param val	: NIL
//@Returntype	: void
//@Author		: Namit Nayak @ Diaspark Inc.
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



- (id) init
{
	self = [super init];
	if (self != nil) 
        {
		
		
        }
	return self;
}

/**
 Returns the directory the application uses to store the Core Data store file. This code uses a directory named "WhatAreYouDoing" in the user's Library directory.
 */
- (NSURL *)applicationFilesDirectory {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSURL *libraryURL = [[fileManager URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject];
    return [libraryURL URLByAppendingPathComponent:@"WhatAreYouDoing"];
}

-(NSString *) getHomedirectoryPath
{
    NSString *homepath=@"~/Library/WhatAreYouDoing/WhatAreYouDoing.sqlite";
   homepath= [homepath stringByExpandingTildeInPath];
    return homepath;
}
-(void)openDataBase
{
	
//    NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
    
//    NSString *path=[[applicationFilesDirectory absoluteString] stringByAppendingFormat:@"/%@.sqlite",FOODFACTS_DATABASE_FILE];
    
    NSString *path=[self getHomedirectoryPath];
    NSLog(@"path:%@",path);

     
    
    NSString *resourceDBPath=[[NSBundle mainBundle] pathForResource:FOODFACTS_DATABASE_FILE ofType:@"sqlite"];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:path])
        {
		sqlite3_open([path UTF8String], &m_pDataBase);
        }
	else 
        {
		NSString *applicationFolder=[path stringByDeletingLastPathComponent];
        NSError *error=nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:applicationFolder withIntermediateDirectories:NO attributes:nil error:&error];
        if(error){
            NSLog(@"creating project directory in library failed! %@",[error localizedDescription]);
            return;
        }
        
        
        
        NSError *err=nil;
        [[NSFileManager defaultManager] copyItemAtPath:resourceDBPath toPath:path error:&err];
        
        
        if(err){
            NSLog(@"error in copy:%@",[err localizedDescription]);
        }
        
		if(!err)			
			sqlite3_open([path UTF8String], &m_pDataBase);
		else
            {
            NSLog(@"Database Creation failed");
            }
        }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//@Method		: closeDataBase
//@Abstract		: This method is responsible for connection Close of Sqlite Database.
//@Param val	: NIL
//@Returntype	: void
//@Author		: Namit Nayak @ Diaspark Inc.
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)closeDataBase
{
	if(m_pDataBase)
        {
		sqlite3_close(m_pDataBase);
		m_pDataBase = nil;
        }
}

-(NSArray*) getLogsFrom:(NSDate*)fromDate to:(NSDate*)toDate{
    
    if(m_pDataBase == nil){
		[self openDataBase];
        
    }	
	
	NSMutableArray *arrayLogs = [[NSMutableArray alloc] init];
	NSLog(@"fromDate:%@ , toDate:%@",[fromDate description],[toDate description]);
	//NSString* sqlQuery = [NSString stringWithFormat:@"SELECT * from Logs where logDate between %@ and %@", fromDate, toDate];	
    
    
	//NSString* sqlQuery=@"SELECT * FROM Logs WHERE logDate BETWEEN '2011-08-05' AND '2011-08-08'";
    toDate=[toDate dateByAddingTimeInterval:86000];
    NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *from=[formatter stringFromDate:fromDate];
    NSString *to=[formatter stringFromDate:toDate];
	NSString* sqlQuery=[NSString stringWithFormat:@"SELECT * FROM Logs WHERE logDate BETWEEN '%@' AND '%@'",from,to];
    NSLog(@"final query:%@",sqlQuery);
    

    
	if(sqlite3_prepare_v2(m_pDataBase, [sqlQuery UTF8String], -1, &m_pSqlStatement, NULL) == SQLITE_OK)
        {
		while (sqlite3_step(m_pSqlStatement) == SQLITE_ROW)
            {			
                LogFile *log=[[LogFile alloc] init];
                
                
                if(sqlite3_column_text(m_pSqlStatement,0))
                    log.timeInterval  = sqlite3_column_int(m_pSqlStatement,0);
                else
                    log.timeInterval  = -1;
                
                
                if(sqlite3_column_text(m_pSqlStatement,1))
                    log.Description  = [NSString stringWithUTF8String: (const char*)sqlite3_column_text(m_pSqlStatement,1)];
                else
                    log.Description  = @"";
                
                if(sqlite3_column_text(m_pSqlStatement,2))
                    log.logDate  = [NSString stringWithUTF8String: (const char*)sqlite3_column_text(m_pSqlStatement,2)];
                else
                    log.logDate  = @"";
                
                [arrayLogs addObject:log];
                
                [log release];                
                
            }
		
        }	
	
	sqlite3_finalize(m_pSqlStatement);	
	[self closeDataBase];
	return [arrayLogs autorelease];
}

// What are you doing database
-(NSArray*) getAllLogs{
    if(m_pDataBase == nil){
		[self openDataBase];
        
    }
	
	
	NSMutableArray *arrayLogs = [[NSMutableArray alloc] init];
	
	NSString* sqlQuery = @"SELECT * from Logs";	
	
	if(sqlite3_prepare_v2(m_pDataBase, [sqlQuery UTF8String], -1, &m_pSqlStatement, NULL) == SQLITE_OK)
        {
		while (sqlite3_step(m_pSqlStatement) == SQLITE_ROW)
            {			
                LogFile *log=[[LogFile alloc] init];
                
                
                if(sqlite3_column_text(m_pSqlStatement,0))
                    log.timeInterval  = sqlite3_column_int(m_pSqlStatement,0);
                else
                    log.timeInterval  = -1;
                
                
                if(sqlite3_column_text(m_pSqlStatement,1))
                    log.Description  = [NSString stringWithUTF8String: (const char*)sqlite3_column_text(m_pSqlStatement,1)];
                else
                    log.Description  = @"";
                
                if(sqlite3_column_text(m_pSqlStatement,2))
                    log.logDate  = [NSString stringWithUTF8String: (const char*)sqlite3_column_text(m_pSqlStatement,2)];
                else
                    log.logDate  = @"";
                
                [arrayLogs addObject:log];
                
                [log release];                
                
            }
		
        }	
	
	sqlite3_finalize(m_pSqlStatement);	
	[self closeDataBase];
	return [arrayLogs autorelease];
}

-(BOOL)addLogsForDate:(NSDate*)logDate Description:(NSString*)desc withInterval:(NSInteger)interval{

    if(m_pDataBase == nil){
		[self openDataBase];
        
    }
    
//    NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
//    [formatter setDateStyle:NSDateFormatterMediumStyle];
//    [formatter setTimeStyle:NSDateFormatterMediumStyle];
//    NSString *dateStr=[formatter stringFromDate:logDate];
//    
//    NSLog(@"logDate:%@ , desc:%@",logDate,desc);
    
    NSString *insertSQL = [NSString stringWithFormat: @"INSERT INTO Logs (timeInterval, Description, logDate) VALUES (\"%i\", \"%@\", \"%@\")", interval, desc, logDate];
    
    const char *insert_stmt = [insertSQL UTF8String];
    
    sqlite3_prepare_v2(m_pDataBase, insert_stmt, -1, &m_pSqlStatement, NULL);
    if (sqlite3_step(m_pSqlStatement) == SQLITE_DONE)
        {
        NSLog(@"Log added");
        
        } else {
//            NSLog(@"Failed to add Log:%@",sqlite3_errmsg(m_pDataBase));
            sqlite3_finalize(m_pSqlStatement);
            sqlite3_close(m_pDataBase);
            return NO;
        }
    sqlite3_finalize(m_pSqlStatement);
    sqlite3_close(m_pDataBase);
    return YES;
}

-(BOOL)removeAllLogs{
    
    if(m_pDataBase == nil){
		[self openDataBase];
        
    }
    
    NSString *deleteSQL = [NSString stringWithFormat: @"delete from Logs"]; // Truncate the table() 
    // Also can be used "delete from Log where rowid>=0"
    
    const char *delete_stmt = [deleteSQL UTF8String];
    
    sqlite3_prepare_v2(m_pDataBase, delete_stmt, -1, &m_pSqlStatement, NULL);
    if (sqlite3_step(m_pSqlStatement) == SQLITE_DONE)
        {
        NSLog(@"logs deleted");
        
        } else {
//            NSLog(@"Failed to delete:%@",sqlite3_errmsg(m_pDataBase));
            sqlite3_finalize(m_pSqlStatement);
            sqlite3_close(m_pDataBase);
            return NO;
        }
    sqlite3_finalize(m_pSqlStatement);
    sqlite3_close(m_pDataBase);
    
    return YES;
}

@end
