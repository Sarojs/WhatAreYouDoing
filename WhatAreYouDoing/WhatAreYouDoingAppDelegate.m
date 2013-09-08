//
//  WhatAreYouDoingAppDelegate.m
//  WhatAreYouDoing
//
//  Created by MAC22 on 14/07/11.
//  Copyright 2011 Diaspark India. All rights reserved.
//

#import "WhatAreYouDoingAppDelegate.h"
#import "DataBaseInterface.h"
#import "LogFile.h"

//#define kSleepTimeInterval 1800.0   // 30 min.
#define kJumpInFrequency 2.0
#define kDefaultNameForToSaveLogFile @"WorkLog"

@implementation WhatAreYouDoingAppDelegate
@synthesize descTextView = _descTextView;

@synthesize timeInterval,fromDatePicker,toDatePicker;

@synthesize window;


- (void)dealloc
{
    [__managedObjectContext release];
    [__persistentStoreCoordinator release];
    [__managedObjectModel release];
    
    [self.timeInterval release];
    [self.fromDatePicker release];
    [self.toDatePicker release];
    
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    
    [DataBaseInterface openDataBase];
//    [window setBackgroundColor:[NSColor blackColor]];
    /*
    CGRect windowFrame = [[window contentView] superview].frame;
    NSTextField *textField=[[NSTextField alloc] initWithFrame:CGRectMake(140,0,150,15)];
    CGRect titleFrame = [textField frame];
    titleFrame.origin.y = windowFrame.size.height - titleFrame.size.height;
    [textField setFrame:titleFrame];
    [textField setEditable:NO];
    [textField setStringValue:@"WhatAreYouDoing ?"];
    [textField setBordered:NO];
    [textField setBackgroundColor:[NSColor blackColor]];
    [textField setTextColor:[NSColor whiteColor]];
    [[[window contentView] superview] addSubview:textField];
    */
    
    [timeInterval removeAllItems];
    NSArray *arrItems=[NSArray arrayWithObjects:@"1",@"2",@"15",@"30",@"45",@"60",@"75",@"90",@"105",@"120", nil];
    [timeInterval addItemsWithTitles:arrItems];
    [timeInterval selectItemAtIndex:1];
    
    
    // start the timer
    [self startRecording];
    
    toDate=nil;
    fromDate=nil;
}


- (void)applicationDidBecomeActive:(NSNotification *)notification{
    NSLog(@"applicationDidBecomeActive");
}

- (void)applicationDidResignActive:(NSNotification *)notification{
    NSLog(@"applicationDidResignActive");        
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag{
    NSLog(@"applicationShouldHandleReopen");
    if(![self.window isVisible]){
        NSLog(@"making window visible");
        [self.window makeKeyAndOrderFront:self];
    }
    
    [self stopRecording];
    
    return YES;
}

-(void)startRecording{
    NSLog(@"startRecording");
    NSMenuItem *item=[timeInterval selectedItem];
    
    NSInteger interval=[[item title] integerValue];
    [self performSelector:@selector(jumpToTheBar) withObject:nil afterDelay:interval*60];
}

-(void)stopRecording{
    NSLog(@"stopRecording");
    
    NSImage *img=[NSImage imageNamed:@"icon.icns"];
    [[NSApplication sharedApplication] setApplicationIconImage:img];
    
    [[NSApplication sharedApplication] cancelUserAttentionRequest:1];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

-(void)jumpToTheBar{
    NSLog(@"jumpToTheBar");
    
    if([[NSApplication sharedApplication] isActive]){
        [self stopRecording];
    }else{
        
        [[NSApplication sharedApplication] requestUserAttention:NSInformationalRequest];
        
        [self performSelector:@selector(jumpToTheBar) withObject:nil afterDelay:kJumpInFrequency];
    }
}

/**
    Returns the directory the application uses to store the Core Data store file. This code uses a directory named "WhatAreYouDoing" in the user's Library directory.
 */
- (NSURL *)applicationFilesDirectory {

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *libraryURL = [[fileManager URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject];
    return [libraryURL URLByAppendingPathComponent:@"WhatAreYouDoing"];
}

/**
    Creates if necessary and returns the managed object model for the application.
 */
- (NSManagedObjectModel *)managedObjectModel {
    if (__managedObjectModel) {
        return __managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"WhatAreYouDoing" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return __managedObjectModel;
}

/**
    Returns the persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
 */
- (NSPersistentStoreCoordinator *) persistentStoreCoordinator {
    if (__persistentStoreCoordinator) {
        return __persistentStoreCoordinator;
    }

    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return nil;
    }

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
    NSError *error = nil;
    
    NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:[NSArray arrayWithObject:NSURLIsDirectoryKey] error:&error];
        
    if (!properties) {
        BOOL ok = NO;
        if ([error code] == NSFileReadNoSuchFileError) {
            ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if (!ok) {
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    else {
        if ([[properties objectForKey:NSURLIsDirectoryKey] boolValue] != YES) {
            // Customize and localize this error.
            NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]]; 
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];
            
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    
    NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:@"WhatAreYouDoing.storedata"];
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]) {
        [[NSApplication sharedApplication] presentError:error];
        [__persistentStoreCoordinator release], __persistentStoreCoordinator = nil;
        return nil;
    }

    return __persistentStoreCoordinator;
}

/**
    Returns the managed object context for the application (which is already
    bound to the persistent store coordinator for the application.) 
 */
- (NSManagedObjectContext *) managedObjectContext {
    if (__managedObjectContext) {
        return __managedObjectContext;
    }

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    __managedObjectContext = [[NSManagedObjectContext alloc] init];
    [__managedObjectContext setPersistentStoreCoordinator:coordinator];

    return __managedObjectContext;
}

/**
    Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
 */
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    return [[self managedObjectContext] undoManager];
}

/**
    Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
 */
- (IBAction) saveAction:(id)sender {

    NSLog(@"saveAction");
    NSString *desc=[[_descTextView textStorage] string];
    if([desc length]==0){
        NSAlert *alert=[NSAlert alertWithMessageText:@"WhatAreYouDoing?" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Blank description is not accepted. Please provide some description"];
        [alert beginSheetModalForWindow:window modalDelegate:nil didEndSelector:nil contextInfo:nil];
        
        return;
    }
    
    NSMenuItem *item=[timeInterval selectedItem];
    NSInteger interval=[[item title] integerValue];
    
    BOOL isSuccess= [DataBaseInterface addLogsForDate:[NSDate date] Description:desc withInterval:interval];
    if(!isSuccess){
        NSAlert *alert=[NSAlert alertWithMessageText:@"WhatAreYouDoing?" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Log could not be saved. Pleae try again."];
        [alert beginSheetModalForWindow:window modalDelegate:nil didEndSelector:nil contextInfo:nil];
        return;
    }
    
    // reset the status text view
    [[[_descTextView textContainer] textView] setString:@""];
    [self stopRecording];
    [self startRecording];
}


-(IBAction)cleanDataBase:(id)sender{
    
    NSAlert *alert=[NSAlert alertWithMessageText:@"WhatAreYouDoing?" defaultButton:@"Yes" alternateButton:@"No" otherButton:nil informativeTextWithFormat:@"Are you sure! you want to delete all entries?"];
    [alert beginSheetModalForWindow:window modalDelegate:self didEndSelector:@selector(cleanDataBaseAlertDidEnd:returnCode:
                                                                                      contextInfo:) contextInfo:nil];
}

-(void)cleanDataBaseAlertDidEnd:(NSAlert*)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo{
    NSLog(@"alert:%d",returnCode);
    BOOL isSuccess=NO;
    if(returnCode==1){
        //delete
        isSuccess=[DataBaseInterface removeAllLogs];
    }
}

-(IBAction)dateFromAction:sender{
    NSLog(@"dateFromAction");
    
    if([fromDatePicker isHidden]==NO){
        [fromDatePicker setHidden:YES];
        return;
    }
    
    [fromDatePicker setHidden:NO];

    if(fromDate==nil){
        [fromDatePicker setDateValue:[NSDate date]];    
    }else{
        [fromDatePicker setDateValue:fromDate];    
    }    
    
    NSButton *btn=(NSButton*)sender;
    NSRect frame=[fromDatePicker frame];
    frame.origin.y=[btn frame].origin.y-[fromDatePicker frame].size.height;
    frame.origin.x=[btn frame].origin.x;
    
    [fromDatePicker setFrame:frame];
}

-(IBAction)selectFromDate:(id)sender{
    NSLog(@"selectFromDate");
    
    NSLog(@"sender:%@",[sender className]);
    [fromDatePicker setHidden:YES];
    fromDate=[fromDatePicker dateValue];
    
    NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM-dd-yyyy"];
    NSString *dateString=[formatter stringFromDate:fromDate];
    [fromDateButton setTitle:dateString];
    NSLog(@"dateString:%@ ",dateString);
}


-(IBAction)dateToAction:sender{
    NSLog(@"dateToAction");
    
    if([toDatePicker isHidden]==NO){
        [toDatePicker setHidden:YES];
        return;
    }
    [toDatePicker setHidden:NO];
    
    if(toDate==nil){
        [toDatePicker setDateValue:[NSDate date]];    
    }else{
        [toDatePicker setDateValue:toDate];    
    }
    
    NSButton *btn=(NSButton*)sender;
    NSRect frame=[toDatePicker frame];
    frame.origin.y=[btn frame].origin.y-[toDatePicker frame].size.height;
    frame.origin.x=[btn frame].origin.x;
    
    [toDatePicker setFrame:frame];
}

-(IBAction)selectToDate:(id)sender{
    NSLog(@"selectToDate");
    
    NSLog(@"sender:%@",[sender className]);
    [toDatePicker setHidden:YES];
    toDate=[toDatePicker dateValue];
    
    NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM-dd-yyyy"];
    NSString *dateString=[formatter stringFromDate:toDate];
    [toDateButton setTitle:dateString];
    NSLog(@"dateString:%@ ",dateString);
}

-(IBAction)importStatusInSelectedDate:(id)sender{
    NSLog(@"importStatusInSelectedDate");
    
    if(fromDate==nil && toDate==nil){
        
        NSAlert *alert=[NSAlert alertWithMessageText:@"WhatAreYouDoing?" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Please select the from and to dates !"];
        [alert beginSheetModalForWindow:window modalDelegate:nil didEndSelector:nil contextInfo:nil];
        
        return;
        
    }else if(fromDate==nil){
        
        NSAlert *alert=[NSAlert alertWithMessageText:@"WhatAreYouDoing?" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Please provide the from date !"];
        [alert beginSheetModalForWindow:window modalDelegate:nil didEndSelector:nil contextInfo:nil];
        
        return;
        
    }else if(toDate==nil){
        
        NSAlert *alert=[NSAlert alertWithMessageText:@"WhatAreYouDoing?" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Please provide the to date !"];
        [alert beginSheetModalForWindow:window modalDelegate:nil didEndSelector:nil contextInfo:nil];
        
        return;
    }

    
    NSArray *arrLogs=[DataBaseInterface getLogsFrom:fromDate to:toDate];
    
    if([arrLogs count]==0){
        NSLog(@"no logs in database");
        NSAlert *alert=[NSAlert alertWithMessageText:@"WhatAreYouDoing?" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"No record is available!"];
        [alert beginSheetModalForWindow:window modalDelegate:nil didEndSelector:nil contextInfo:nil];
        
        return;
    }
    
    LogFile *log=nil;
    
    NSString * zStr = [[NSString alloc]init];
    zStr=@"\t ##### What you WERE doing #####\n\n\n";
    
    NSInteger count=[arrLogs count];
    
    for (NSInteger i = 0; i < count; i++) {
        log =[arrLogs objectAtIndex:i];
        NSLog(@"%@, %@",log.logDate,log.Description);
        
        zStr = [zStr stringByAppendingFormat:@"%i) WithInterval:%ld  \t Time:%@  \t Status:%@\n",i+1,log.timeInterval,log.logDate,log.Description];
        NSLog(@"zStr:%@",zStr);
    }
    
    // get the file url
    NSSavePanel * zSavePanel = [NSSavePanel savePanel];
    
    NSDateFormatter *formatter=[[NSDateFormatter alloc]  init];
    [formatter setDateFormat:@"MM-dd-yyyy"];
    NSString *fileName=[NSString stringWithFormat:@"%@ from %@ to %@.txt",kDefaultNameForToSaveLogFile,[formatter stringFromDate:fromDate],[formatter stringFromDate:toDate]];
    [zSavePanel setNameFieldStringValue:fileName];
    [formatter release];
    
    NSString *defaultPath=@"~/Desktop";
    [zSavePanel setDirectory:defaultPath];
    zSavePanel.title = @"WhatAreYouDoing? - Save Logs";
    zSavePanel.canCreateDirectories = true;
    zSavePanel.showsHiddenFiles = true;
    
    NSInteger zResult = [zSavePanel runModal];
    if (zResult == NSFileHandlingPanelCancelButton) {
        NSLog(@"writeUsingSavePanel cancelled");
        return;
    }
    NSURL *zUrl = [zSavePanel URL];
    
    //write
    BOOL zBoolResult = [zStr writeToURL:zUrl 
                             atomically:YES 
                               encoding:NSASCIIStringEncoding 
                                  error:NULL];
    if (! zBoolResult) {
        NSLog(@"writeUsingSavePanel failed");
    }else{
        NSLog(@"writeUsingSavePanel completed");
    }
}

-(IBAction)importStatusClicked:(id)sender{
    NSLog(@"importStatusClicked");
    [self writeUsingSavePanel];
}

// import to text file
- (void)writeUsingSavePanel {
    // create the string to be written   
    
    NSArray *arrLogs=[DataBaseInterface getAllLogs];
    if([arrLogs count]==0){
        NSLog(@"no logs in database");
        NSAlert *alert=[NSAlert alertWithMessageText:@"WhatAreYouDoing?" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"No record is available!"];
        [alert beginSheetModalForWindow:window modalDelegate:nil didEndSelector:nil contextInfo:nil];
        
        return;
    }
    
    LogFile *log=nil;
    
    NSString * zStr = [[NSString alloc]init];
    zStr=@"\t ##### What you WERE doing #####\n\n\n";
    
    NSInteger count=[arrLogs count];
    
    for (NSInteger i = 0; i < count; i++) {
        log =[arrLogs objectAtIndex:i];
        NSLog(@"%@, %@",log.logDate,log.Description);
        
        zStr = [zStr stringByAppendingFormat:@"%i) WithInterval:%ld  \t Time:%@  \t Status:%@\n",i+1,log.timeInterval,log.logDate,log.Description];
        NSLog(@"zStr:%@",zStr);
    }
    
    // get the file url
    NSSavePanel * zSavePanel = [NSSavePanel savePanel];
    
    NSString *defaultPath=@"~/Desktop";
    [zSavePanel setDirectory:defaultPath];
    
    NSString *fileName=[NSString stringWithFormat:@"All %@.txt",kDefaultNameForToSaveLogFile];
    [zSavePanel setNameFieldStringValue:fileName];
    
    zSavePanel.title = @"WhatAreYouDoing? - Save Logs";
    zSavePanel.canCreateDirectories = true;
    zSavePanel.showsHiddenFiles = true;
    
    NSInteger zResult = [zSavePanel runModal];
    if (zResult == NSFileHandlingPanelCancelButton) {
        NSLog(@"writeUsingSavePanel cancelled");
        return;
    }
    NSURL *zUrl = [zSavePanel URL];
    
    //write
    BOOL zBoolResult = [zStr writeToURL:zUrl 
                             atomically:YES 
                               encoding:NSASCIIStringEncoding 
                                  error:NULL];
    if (! zBoolResult) {
        NSLog(@"writeUsingSavePanel failed");
    }else{
        NSLog(@"writeUsingSavePanel completed");
    }
}


- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {

    // Save changes in the application's managed object context before the application terminates.
    NSLog(@"applicationShouldTerminate");
    if (!__managedObjectContext) {
        return NSTerminateNow;
    }

    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }

    if (![[self managedObjectContext] hasChanges]) {
        return NSTerminateNow;
    }

    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {

        // Customize this code block to include application-specific recovery steps.              
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }

        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];

        NSInteger answer = [alert runModal];
        [alert release];
        alert = nil;
        
        if (answer == NSAlertAlternateReturn) {
            return NSTerminateCancel;
        }
    }

    return NSTerminateNow;
}


#pragma mark- interval delegates
/*
- (BOOL)textShouldBeginEditing:(NSText *)textObject{
    NSLog(@"textShouldBeginEditing");
    return YES;
}
- (BOOL)textShouldEndEditing:(NSText *)textObject{
    NSLog(@"textShouldEndEditing");
    return YES;
}
- (void)textDidChange:(NSNotification *)notification{
    NSLog(@"textDidChange");
    
    if([notification object]==_descTextView){
        NSLog(@"_descTextView:%@",[[_descTextView textStorage] string]);
    }else{
        NSLog(@"textDidChange:%@",[_intervalTextField stringValue]);
    }
}

- (void)textDidBeginEditing:(NSNotification *)notification{
    NSLog(@"textDidBeginEditing");
    
    if([notification object]==_descTextView){
        NSLog(@"_descTextView");
    }else{
        NSLog(@"textDidChange");
    }
    
}
- (void)textDidEndEditing:(NSNotification *)notification{
    NSLog(@"textDidEndEditing:%@",[notification description]);

    if([notification object]==_descTextView){
        NSLog(@"_descTextView");
    }else{
        NSLog(@"textDidChange");
    }
}

- (void)didChangeText{
    NSLog(@"didChangeText");
}
*/

@end
