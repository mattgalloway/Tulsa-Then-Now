//
//  ObjectFactory.m
//
//  Created by Matt Galloway on 1/5/2012.
//  Copyright 2012 Architactile LLC. All rights reserved.
//

#import "ObjectFactory.h"
#import "Photo.h"

#define DEFAULT_PERSISTENT_STORE_FILENAME @"PersistenceStore.db"

@interface ObjectFactory ()

- (void) mergeNotificationIntoMainContext:(NSNotification *)notification;
- (void) savedMOCNotificationReceived: (NSNotification *) notification; 
- (void) registerToListenForSavesToMOC:(NSManagedObjectContext *)thisMOC;

@end

@implementation ObjectFactory

static ObjectFactory *_sharedInstance = nil;
static NSMutableDictionary *_threadMOCs = nil;
static NSString *_persistentStoreFilename = nil;

#pragma mark - Custom methods to create new managed objects 

-(Photo *) newPhoto{
    return (Photo *) [self newObjectForEntityName:@"Photo"];
}

#pragma mark - Custom methods to fetch objects

- (NSArray *) getPhotos {
    NSFetchedResultsController *fetchedResultsController = [[self newFetchedResultsControllerForEntity:@"Photo" 
                                                                                         sortedFirstBy:@"contentDMNumber" 
                                                                                           thenByOrNil:nil
                                                                                           thenByOrNil:nil
                                                                                       filteredByOrNil:nil
                                                                                    sectionNameKeyPath:nil 
                                                                                              delegate:nil ] autorelease];
    NSError *error;
	if (![fetchedResultsController performFetch:&error]) {
		NSLog(@"Error Fetching Photo %@",[error localizedDescription]);
        return nil;
    }
    
    return fetchedResultsController.fetchedObjects; 
}

-(Photo *) getPhotoWithCDMNumber:(long) cDMNumber {

    NSFetchedResultsController *fetchedResultsController = [[self newFetchedResultsControllerForEntity:@"Photo" 
                                                                                         sortedFirstBy:@"contentDMNumber" 
                                                                                           thenByOrNil:nil
                                                                                           thenByOrNil:nil
                                                                                       filteredByOrNil:[NSPredicate predicateWithFormat:@"contentDMNumber =  %i ",cDMNumber]
                                                                                    sectionNameKeyPath:nil 
                                                                                              delegate:nil ] autorelease];
	NSError *error;
	if (![fetchedResultsController performFetch:&error]) 
		NSLog(@"Error Fetching Photo %@",[error localizedDescription]);
    
	if ([fetchedResultsController.fetchedObjects count]==0) {
        NSLog(@"No photo found with contentDM Number %ld",cDMNumber);
		return nil;
	}
    
    if ([fetchedResultsController.fetchedObjects count]>1) {
        NSLog(@"More than one photo found with contentDM Number %ld",cDMNumber);
	}
	
	return (Photo *)[fetchedResultsController.fetchedObjects lastObject];    
}

#pragma mark -
#pragma mark Singleton sharedInstance

// Object Factory is a singleton so there's only one instance per application. To instantiate, you don't call 
// init, instead you call the "sharedInstance" method and you will get the one and only instance of the
// ObjectFactory for the app.
//
// Should look something like this in your code:
//
// ObjectFactory *myObjectFactory = [ObjectFactory sharedInstance];
//



+(int) fileSizeOfItemAtPath:(NSString *) filename {
    
    NSFileManager *fm = [[NSFileManager alloc] init];

    if (![fm fileExistsAtPath:filename]) return 0;
    
    NSError *error=nil;
    
    NSDictionary *fileAttributes = [fm attributesOfItemAtPath:filename error:&error];
    
    if (error!=nil || fileAttributes==nil) return 0;
    
    NSString *fileSize = [fileAttributes objectForKey:NSFileSize];
    
    return [fileSize intValue];
}


+ (ObjectFactory *) sharedInstance {
	if (!_sharedInstance)
	{
		NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];

		NSString *fromPath = [[NSBundle mainBundle] pathForResource:[ObjectFactory modelName] ofType:[ObjectFactory persistentStoreExtension]];
        
		NSString *toPath = [docDir stringByAppendingPathComponent:[ObjectFactory persistentStoreFilename]];
		NSFileManager *fm = [[NSFileManager alloc] init];
        
        
        int fromSize = [ObjectFactory fileSizeOfItemAtPath:fromPath];
        int toSize = [ObjectFactory fileSizeOfItemAtPath:toPath];
        
		if ((![fm fileExistsAtPath:toPath] && [fm fileExistsAtPath:fromPath]) || fromSize!=toSize ) {
            NSLog(@"Copying database");
			NSError *error;
			if (![fm copyItemAtPath:fromPath toPath:toPath error:&error])
				NSLog(@"Error moving %@ to %@ %@",fromPath,toPath,[error localizedDescription]);
		}
		[fm release];
		_sharedInstance = [[self alloc] init];
	}
	return _sharedInstance;
}

#pragma mark -
#pragma mark Thread Synchronizing Stuff

// There needs to be one Model Object Context (MOC) for each thread in a multithreaded app. 
// When a thread other than the Main thread makes a change, a notification needs to be sent 
// to the main thread so the change can be synchonized. 
//
// This code assumes that the background threads are making changes and notifying the main thread. 
// There is NO CODE here to notify the background threads in the event of a change in the main thread. 
// This is because I typically only use background threads for data access in order to keep the UI "alive"
// so I assume that nothing in the main thread is going to change the data during these processes. 
//
// Note that this may NOT be the case for your app. So be aware.
//
// The methods in this section are invoked when data changes are detected in a background thread. They are 
// plugged into CoreData the first time a MOC is created for a given thread and killed when the thread 
// goes away.



- (void) mergeNotificationIntoMainContext:(NSNotification *)notification {
    // This should be running on the main thread
    [self.managedObjectContext mergeChangesFromContextDidSaveNotification:notification];    
    [self save];
}

- (void) savedMOCNotificationReceived: (NSNotification *) notification {
    [self performSelectorOnMainThread:@selector(mergeNotificationIntoMainContext:) withObject:notification waitUntilDone:NO];
}

- (void) registerToListenForSavesToMOC:(NSManagedObjectContext *)thisMOC {
    [[NSNotificationCenter defaultCenter]
     addObserver: self
     selector: @selector(savedMOCNotificationReceived:)
     name: NSManagedObjectContextDidSaveNotification  object: thisMOC];
}

#pragma mark -
#pragma mark Save, Delete, Etc 

// The save and delete functions are pretty straight forward.  Calling "save" on the sharedInsaance of the 
// ObjectFactory it will flush and dirty data to disk.  If the data isn't dirty it does nothing. 
//
// For mobile apps you want to call "save" often. Maybe as often as after every field level edit.
//
// Unlike "save" the "deleteObject" method requires an object. Passing any of your CoreData data objects
// to this method will mark it for deletion (and follow all cascading rules defined in the model).  The ACTUAL 
// delete doesn't happen until the next time you call the "save" method.
//
// The "deleteObjectAndSave" method is a conveinence mthod that marks for deletion and persists the deletion all
// in one swoop.
//

- (void) save {
	NSError *error = nil;
	if (self.managedObjectContext != nil) {
		if ([self.managedObjectContext hasChanges] && ![self.managedObjectContext save:&error]) {
			/*
			 Replace this implementation with code to handle the error appropriately.
			 
			 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
			 */
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			abort();
		}
	}
}

- (void) deleteObject:(NSManagedObject *)objectToDelete {
	[self.managedObjectContext deleteObject:objectToDelete];
}
- (void) deleteObjectAndSave:(NSManagedObject *)objectToDelete {
	[self deleteObject:objectToDelete];
	[self save];
}

#pragma mark -
#pragma mark Object Factory Methods

// This method creates a persistent object from the model given an entity name. You can cll this method directly
// but I prefer to create class specific wrappers, see below.

- (NSManagedObject *) newObjectForEntityName:(NSString *)entityName {
	NSManagedObject *retObj =  (NSManagedObject *) [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:self.managedObjectContext];
	return [retObj retain];
}

// Once we create a model, and code generate classes for the entities from the model, we can create wrapper
// methods that produce fully formed objects of the specified class instead of the overly  NSManagedObject
// We'll implement this in a class that inherits from ObjectFactory.  The wrapper methods will follow 
// this template:
/* 
 
 - (CLASSNAME *) newCLASSNAME {
 return (CLASSNAME *) [self newObjectForEntityName:@"CLASSNAME"];
 }
 
 */

// So, for example, if we had an entity called "Foo" and we code generated Foo.m and Foo.h then we could do this:

/* 
 
 - (Foo *) newFoo {
 return (Foo *) [self newObjectForEntityName:@"Foo"];
 }
 
 */

// Then, in our code when we need a "Foo" we do this:
//
// Foo *aFoo = [objectFactory newFoo];
//
// 

#pragma mark -
#pragma mark Fetched Results Controller Factories

// Getting a collection of objects out of CoreData is done through a thing called a FetchedResultController.  This
// method makes create one a little easier.  

- (NSFetchedResultsController *)newFetchedResultsControllerForEntity:(NSString *)entityName
													   sortedFirstBy:(NSString *)firstSort
														 thenByOrNil:(NSString *)secondSort
														 thenByOrNil:(NSString *)thirdSort
													 filteredByOrNil:(NSPredicate *)filterPredicate
												  sectionNameKeyPath:(NSString *)sectionNameKeyPath
															delegate:(id <NSFetchedResultsControllerDelegate>) delegate 
{
    /*
     Set up the fetched results controller.
     */
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	// Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
    
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
	NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:firstSort ascending:YES];
    NSSortDescriptor *sortDescriptor2 = nil;
    NSSortDescriptor *sortDescriptor3 = nil;
	
	NSArray *sortDescriptors;
	if (secondSort == nil)
	{
		sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor1, nil];
	} else {
		if (thirdSort == nil)
		{
			sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:secondSort ascending:YES];
			sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor1, sortDescriptor2, nil];
		} else {
			sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:secondSort ascending:YES];
			sortDescriptor3 = [[NSSortDescriptor alloc] initWithKey:thirdSort ascending:YES];
			sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor1, sortDescriptor2, sortDescriptor3, nil];
		}
    }
    
    [fetchRequest setSortDescriptors:sortDescriptors];
	
	if (filterPredicate != nil)
	{
		[fetchRequest setPredicate:filterPredicate];
    }
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
	
	// cacheName changed to "nil" from @"Root" to try to make some caching problems disappear (which it seems to have done)
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
																								managedObjectContext:self.managedObjectContext 
                                                                                                  sectionNameKeyPath:sectionNameKeyPath
                                                                                                           cacheName:nil];
	if (delegate != nil)
	{
		aFetchedResultsController.delegate = delegate;
	}
    
    [fetchRequest release];
    [sortDescriptor1 release];
	[sortDescriptor2 release];
	[sortDescriptor3 release];
    [sortDescriptors release];
    
    return aFetchedResultsController;
}  


// To handle threaded access to our store, we create a MOC for each thread and since the ObjectFactory is
// a singleton the MOCs hang around after the threads go away. So when you want to use the Object Factory in a a thread
// other than the main thread you need to first name the thread (this name will be used to keep track of which MOC 
// belongs to it. Then, just before you're done with your thread, call "thisThreadFinishedwithObjectFactory" this will
// save any dirty data and then release the MOC for the thread.
//
// So your thread code should look like this:
//
// [[NSThread currentThread].name = "My Thread Name";
//
// ObjectFactory *gof = [ObjectFactory sharedInstance];
//
// (do stuff with the Object Factory)
//
// [gof thisThreadFinishedWithObjectFactory];
//


#pragma mark -
#pragma mark Thread Specific MOC Clean Up

-(void) thisThreadFinishedWithObjectFactory {
    NSThread *thisThread = [NSThread currentThread];
    NSString *threadName = ([thisThread isMainThread]?@"Main":[thisThread name]);
    if (threadName == nil) {
        NSLog(@"Hey, you're not supposed to be calling this unless you've named your thread!.");
        abort();
    }
    [self save];
    if (_threadMOCs != nil) {
        [_threadMOCs removeObjectForKey:threadName];
    }
}

// We maintain one MOC for each thread.  This method returns the correct MOC for us. You should almost never need
// to call this methid directly.

#pragma mark -
#pragma mark Managed Object Context

- (NSManagedObjectContext *) managedObjectContext {
    
    NSManagedObjectContext *thisMOC = nil;
    
    NSThread *thisThread = [NSThread currentThread];
    NSString *threadName = ([thisThread isMainThread]?@"Main":[thisThread name]);
    
    if (_threadMOCs == nil) {
        _threadMOCs = [[NSMutableDictionary dictionaryWithCapacity:5] retain];
    }
    if (threadName == nil) {
        NSLog(@"Not so fast! Unnamed thread attempted to request a MOC in ObjectFactory instance.");
        abort();
    }
    thisMOC = (NSManagedObjectContext *)[_threadMOCs objectForKey:threadName];   
	
    if (thisMOC == nil) {
        NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
        if (coordinator != nil) {
            thisMOC = [[[NSManagedObjectContext alloc] init] autorelease];
            [thisMOC setPersistentStoreCoordinator: coordinator];
            [_threadMOCs setObject:thisMOC forKey:threadName];
            
            if (![thisThread isMainThread]) {
                [self performSelectorOnMainThread:@selector(registerToListenForSavesToMOC:) withObject:thisMOC waitUntilDone:YES];
            }
        } else {
            NSLog(@"ERROR: No NSPersistentStoreCoordinator");
            return nil;
        }
    }
    return thisMOC;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
	
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    
    //NSLog(@"[ObjectFactory modelName] : %@",[ObjectFactory modelName]);
    //NSLog(@"[ObjectFactory persistentStoreExtension] : %@",[ObjectFactory persistentStoreExtension]);
    //NSLog(@"[ObjectFactory persistentStoreFilename] : %@",[ObjectFactory persistentStoreFilename]);
	
	NSString *path = [[NSBundle mainBundle] pathForResource:[ObjectFactory modelName] ofType:@"momd"];
    //NSLog(@"core data filepath: %@",path);
	NSURL *momURL = [NSURL fileURLWithPath:path];
	_managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:momURL];
	
    return _managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
	NSString *applicationDocumentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *dbPath = [applicationDocumentDirectory stringByAppendingPathComponent: [ObjectFactory persistentStoreFilename]];
    
    NSURL *storeUrl = [NSURL fileURLWithPath: dbPath];
    
    NSString *prefilledDB = [[NSBundle mainBundle] pathForResource:[ObjectFactory modelName] ofType:@"db"];
    
    if (prefilledDB != nil) {
        
        NSFileManager *fm = [[NSFileManager alloc] init];
        
        if (![fm fileExistsAtPath:dbPath]) {
            [fm copyItemAtPath:prefilledDB toPath:dbPath error:nil];
        }
        
        [fm release];
    }
	
	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
							 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
							 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
							 nil];
    
	NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error]) {
		/*
		 Replace this implementation with code to handle the error appropriately.
		 
		 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
		 
		 Typical reasons for an error here include:
		 * The persistent store is not accessible
		 * The schema for the persistent store is incompatible with current managed object model
		 Check the error message to determine what the actual problem was.
		 */
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
    }    
	
    return _persistentStoreCoordinator;
}

#pragma mark - Persistent Store Name

/*
    Ultimately Core Data is backed by a SQL Lite database.  You can specify the file name by setting the 
    static NSString _persistentStoreFilename. If you don't the default value "PersistentStore.db" will be used.
*/

+ (NSString *) modelName {
    return [[[ObjectFactory persistentStoreFilename] lastPathComponent] stringByDeletingPathExtension];
}

+ (NSString *) persistentStoreExtension {
    return [[ObjectFactory persistentStoreFilename] pathExtension];
}

+ (NSString *) persistentStoreFilename {
    if (_persistentStoreFilename==nil) return DEFAULT_PERSISTENT_STORE_FILENAME;
    return _persistentStoreFilename;
}

+(void) setPersistentStoreFilename:(NSString *)filename {
    if (_persistentStoreFilename!=nil) {
        NSLog(@"Persistent store filename already set to %@ ignoreing %@",_persistentStoreFilename,filename);
        return;
    }
    _persistentStoreFilename=filename;
    [_persistentStoreFilename retain];
}

#pragma mark -
#pragma mark Data Fetching Methods
- (NSManagedObject *) objectWithID:(NSManagedObjectID *)objectID {
    return [self.managedObjectContext objectWithID:objectID];
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[_managedObjectContext release];
    [_managedObjectModel release];
    [_persistentStoreCoordinator release];
	[super dealloc];
}
@end
