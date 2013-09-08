//
//  WhatAreYouDoingAppDelegate.h
//  WhatAreYouDoing
//
//  Created by MAC22 on 14/07/11.
//  Copyright 2011 Diaspark India. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface WhatAreYouDoingAppDelegate : NSObject <NSApplicationDelegate,NSTextViewDelegate,NSTextFieldDelegate,NSAlertDelegate> {
@private
    NSWindow *window;
    NSPersistentStoreCoordinator *__persistentStoreCoordinator;
    NSManagedObjectModel *__managedObjectModel;
    NSManagedObjectContext *__managedObjectContext;
    
    NSDate *fromDate;
    NSDate *toDate;
    
    IBOutlet NSButton *fromDateButton;
    IBOutlet NSButton *toDateButton;
    
    
    NSTextView *_descTextView;
    
}


@property (assign) IBOutlet NSWindow *window;
// Controls
@property (assign) IBOutlet NSTextView *descTextView;
@property(nonatomic,retain) IBOutlet NSPopUpButton *timeInterval;
@property(nonatomic,retain) IBOutlet NSDatePicker *fromDatePicker;
@property(nonatomic,retain) IBOutlet NSDatePicker *toDatePicker;

@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;


-(IBAction)dateFromAction:sender;
-(IBAction)dateToAction:sender;

-(IBAction)saveAction:sender;
-(IBAction)importStatusInSelectedDate:(id)sender;
-(IBAction)importStatusClicked:(id)sender;
-(IBAction)cleanDataBase:(id)sender;

// Date time
-(IBAction)selectFromDate:(id)sender;

-(void)startRecording;
-(void)stopRecording;
-(void)jumpToTheBar;
- (void)writeUsingSavePanel;

@end
