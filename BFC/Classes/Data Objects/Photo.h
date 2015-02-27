//
//  Photo.h
//  BFC
//
//  Created by Matt Galloway on 1/23/12.
//  Copyright (c) 2012 Architactile LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Photo : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * subject;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSString * digitalPublisher;
@property (nonatomic, retain) NSString * date;
@property (nonatomic, retain) NSString * creator;
@property (nonatomic, retain) NSString * rights;
@property (nonatomic, retain) NSString * contributors;
@property (nonatomic, retain) NSString * relation;
@property (nonatomic, retain) NSString * verified;
@property (nonatomic, retain) NSString * modified;
@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * app;
@property (nonatomic, retain) NSString * source;
@property (nonatomic, retain) NSString * dateCreated;
@property (nonatomic, retain) NSString * dateModified;
@property (nonatomic, retain) NSString * referenceURL;
@property (nonatomic, retain) NSNumber * contentDMNumber;
@property (nonatomic, retain) NSString * contentDMFilepath;
@property (nonatomic, retain) NSString * contentDMFilename;
@property (nonatomic, retain) NSNumber * coord_lat;
@property (nonatomic, retain) NSNumber * coord_long;

@end
