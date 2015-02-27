//
//  ObjectFactory.m
//
//  Created by Matt Galloway on 1/5/2012.
//  Copyright 2012 Architactile LLC. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@class Photo;

@interface ObjectFactory : NSObject {
        
	@private
		NSManagedObjectModel *_managedObjectModel;
		NSManagedObjectContext *_managedObjectContext;	    
		NSPersistentStoreCoordinator *_persistentStoreCoordinator;
}

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (ObjectFactory *) sharedInstance;
+ (NSString *) modelName;
+ (NSString *) persistentStoreExtension;
+ (void) setPersistentStoreFilename:(NSString *)filename;
+ (NSString *) persistentStoreFilename;
- (void) save;
- (void) deleteObject:(NSManagedObject *)objectToDelete;
- (void) deleteObjectAndSave:(NSManagedObject *)objectToDelete;
- (void) thisThreadFinishedWithObjectFactory;
- (NSManagedObject *) newObjectForEntityName:(NSString *)entityName;
- (NSManagedObject *) objectWithID:(NSManagedObjectID *)objectID;
- (NSFetchedResultsController *)newFetchedResultsControllerForEntity:(NSString *)entityName
													   sortedFirstBy:(NSString *)firstSort
														 thenByOrNil:(NSString *)secondSort
														 thenByOrNil:(NSString *)thirdSort
													 filteredByOrNil:(NSPredicate *)filterPredicate
												  sectionNameKeyPath:(NSString *)sectionNameKeyPath
															delegate:(id <NSFetchedResultsControllerDelegate>) delegate ;

- (Photo *) newPhoto;
- (Photo *) getPhotoWithCDMNumber:(long) cDMNumber;
- (NSArray *) getPhotos;

@end
