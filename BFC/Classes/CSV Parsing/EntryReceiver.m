//
//  EntryReceiver.m
//  CSVImporter
//
//  Created by Matt Gallagher on 2009/11/30.
//  Copyright 2009 Matt Gallagher. All rights reserved.
//
//  This software is provided 'as-is', without any express or implied
//  warranty. In no event will the authors be held liable for any damages
//  arising from the use of this software. Permission is granted to anyone to
//  use this software for any purpose, including commercial applications, and to
//  alter it and redistribute it freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//     claim that you wrote the original software. If you use this software
//     in a product, an acknowledgment in the product documentation would be
//     appreciated but is not required.
//  2. Altered source versions must be plainly marked as such, and must not be
//     misrepresented as being the original software.
//  3. This notice may not be removed or altered from any source
//     distribution.
//

#import "EntryReceiver.h"

@implementation EntryReceiver

//
// initWithContext:
//
// Parameters:
//    aContext - the context into which records will be added.
//    entityName - the name of the NSEntityDescription to use for new
//		managedObjects added to the context.
//
// returns the initialized object.
//
- (id)initWithContext:(NSManagedObjectContext *)aContext
	entityName:(NSString *)entityName
{
	self = [super init];
	if (self)
	{
		context = [aContext retain];
		entityDescription =
			[[NSEntityDescription
				entityForName:entityName
				inManagedObjectContext:context]
			retain];
	}
	return self;
}

//
// dealloc
//
// Releases instance memory.
//
- (void)dealloc
{
	[context release];
	[entityDescription release];
	[super dealloc];
}


//
// receiveRecord:
//
// Receives a row from the CSVParser
//
// Parameters:
//    aRecord - the row
//
- (void)receiveRecord:(NSDictionary *)aRecord
{
	NSManagedObject *managedObject =
		[[[NSManagedObject alloc]
			initWithEntity:entityDescription
			insertIntoManagedObjectContext:context]
		autorelease];
	NSDictionary *attributesByName = [entityDescription attributesByName];	
	
	for (NSString *key in aRecord)
	{
		NSAttributeDescription *attributeDescription =
			[attributesByName objectForKey:key];
		if (attributeDescription)
		{
			switch([attributeDescription attributeType])
			{
			case NSInteger64AttributeType:
			case NSInteger32AttributeType:
			case NSInteger16AttributeType:
				[managedObject
					setValue:
						[NSNumber numberWithLongLong:[[aRecord objectForKey:key] longLongValue]]
					forKey:key];
				break;
			case NSDecimalAttributeType:
				[managedObject
					setValue:
						[NSDecimalNumber decimalNumberWithString:[aRecord objectForKey:key]]
					forKey:key];
				break;
			case NSDoubleAttributeType:
			case NSFloatAttributeType:
				[managedObject
					setValue:
						[NSNumber numberWithDouble:[[aRecord objectForKey:key] doubleValue]]
					forKey:key];
				break;
			default:
				[managedObject setValue:[aRecord objectForKey:key] forKey:key];
				break;
			}
		}
	}
}

@end
