//
//  DataLoader.m
//  BFC
//
//  Created by Matt Galloway on 1/23/12.
//  Copyright (c) 2012 Architactile LLC. All rights reserved.
//

#import "DataLoader.h"
#import "ObjectFactory.h"
#import "Photo.h"
#import "CSVParser.h"
#import "EntryReceiver.h"

@implementation DataLoader


+(void) loadCSVFile:(NSString *) csvPath {

    
    ObjectFactory *of = [ObjectFactory sharedInstance];
    
    NSString *csvFilePath = [[NSBundle mainBundle] pathForResource:@"AppData" ofType:@"csv"];  
    
    NSError *error;
	NSString *csvString = [NSString stringWithContentsOfFile:csvFilePath encoding:NSUTF8StringEncoding error:&error];
    
	if (!csvString)
	{
		printf("Couldn't read file at path %s\n. Error: %s",
               [csvFilePath UTF8String],
               [[error localizedDescription] ? [error localizedDescription] : [error description] UTF8String]);
        return;
	}
	
	
	EntryReceiver *receiver =
    [[[EntryReceiver alloc]
      initWithContext:of.managedObjectContext
      entityName:@"Photo"] autorelease];
	CSVParser *parser =
    [[[CSVParser alloc]
      initWithString:csvString
      separator:@","
      hasHeader:NO
      fieldNames:
      [NSArray arrayWithObjects:
       @"title",
       @"subject",
       @"desc",
       @"digitalPublisher",
       @"date",
       @"creator",
       @"rights",
       @"contributors",
       @"relation",
       @"verified",
       @"modified",
       @"address",
       @"app",
       @"source",
       @"dateCreated",
       @"dateModified",
       @"referenceURL",
       @"contentDMNumber",
       @"contentDMFilename",
       @"contentDMFilepath",
       @"coord_lat",
       @"coord_long",
       nil]]
     autorelease];
	[parser parseRowsForReceiver:receiver selector:@selector(receiveRecord:)];

    [of save];
    
    NSLog(@"Data Loaded");
}

@end
