//
//  CatalogueInfo.m
//  DatabaseExample
//
//  Created by MAC22 on 07/07/11.
//  Copyright 2011 Diaspark India. All rights reserved.
//

#import "LogFile.h"


@implementation LogFile
@synthesize timeInterval;
@synthesize Description;
@synthesize logDate;

-(void)dealloc{
    
    [self.Description release];
    [self.logDate release];
    [super dealloc];
    
}
@end
