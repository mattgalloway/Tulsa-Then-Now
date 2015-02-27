//
//  AppDelegate.m
//  BFC
//
//  Created by Matt Galloway on 1/22/12.
//  Copyright (c) 2012 Architactile LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "ObjectFactory.h"
#import "DataLoader.h"
#import "Photo.h"
#import "PhotoLocation.h"

#define FACEBOOK_APP_ID @"205608116210590" 

@implementation AppDelegate

@synthesize window = _window;
@synthesize tabBarController=_tabBarController;
@synthesize photoLocations=_photoLocations;
@synthesize facebook=_facebook;

// Pre iOS 4.2 support
//- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
//    return [self.facebook handleOpenURL:url]; 
//}

// For iOS 4.2+ support
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [self.facebook handleOpenURL:url]; 
}

- (void)fbDidLogin {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[self.facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[self.facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    //NSLog(@"FACEBOOK: Did login");
    if (currentLoop!=nil) {
        CFRunLoopStop(currentLoop);
        currentLoop=nil;
    }
}

- (void)fbDidNotLogin:(BOOL)cancelled{
    //NSLog(@"FACEBOOK: Did NOT login");
    if (currentLoop!=nil) {
        CFRunLoopStop(currentLoop);
        currentLoop=nil;
    }
}

- (void)fbDidExtendToken:(NSString*)accessToken
               expiresAt:(NSDate*)expiresAt{}
- (void)fbDidLogout{
    //NSLog(@"FACEBOOK: Did logout");
}
- (void)fbSessionInvalidated{
    //NSLog(@"FACEBOOK: Session Validated");
}

- (void)requestLoading:(FBRequest *)request{
    //NSLog(@"FACEBOOK: requestLoading");
}
- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response{
    //NSLog(@"FACEBOOK: didReceiveResponse");
}
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error{
    //NSLog(@"FACEBOOK: didFailWithError");
    if (currentLoop!=nil) {
        CFRunLoopStop(currentLoop);
        currentLoop=nil;
    }
    facebookPostError=error;
}
- (void)request:(FBRequest *)request didLoad:(id)result{
    //NSLog(@"FACEBOOK: didLoad %@",result);
    if (currentLoop!=nil) {
        CFRunLoopStop(currentLoop);
        currentLoop=nil;
    }
}
- (void)request:(FBRequest *)request didLoadRawResponse:(NSData *)data{
    //NSLog(@"FACEBOOK: didLoadRawResponse");
}

-(BOOL) facebookLogin {
    if (![self.facebook isSessionValid]) {
        currentLoop=CFRunLoopGetCurrent();
        NSArray *permissions =  [NSArray arrayWithObjects:@"publish_stream",@"offline_access",nil]; 
        [self.facebook authorize:permissions];
        CFRunLoopRun();
    } 
    
    return [self.facebook isSessionValid];
}

-(BOOL) isFacebookSessionValid {
    return [self.facebook isSessionValid];
}

-(NSError *) postToFacebookWithText:(NSString *)text andImage:(UIImage *)image {
    currentLoop=CFRunLoopGetCurrent();
    facebookPostError=nil;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   text, @"message",  
                                   image, @"picture",   
                                   nil];
    [self.facebook requestWithGraphPath:@"me/photos"
                                    andParams:params
                                andHttpMethod:@"POST"
                                  andDelegate:self];
    
    CFRunLoopRun();
    
    return facebookPostError;
}


-(void) fetchPhotos {
    
    NSArray *photos = [[ObjectFactory sharedInstance] getPhotos];
    
    self.photoLocations = [NSMutableArray arrayWithCapacity:[photos count]];
    
//    int photoCount = 0;
    
    for (Photo *photo in photos) {
        /*
        NSLog(@"%i,%@,%@,%@",++photoCount,photo.contentDMNumber,photo.coord_lat,photo.coord_long);
        NSString *imagePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@",photo.contentDMNumber] ofType:@"jpg" inDirectory:@"BFC_Selected_Images.bundle"];
        if (imagePath==nil) {
            NSLog(@"%@ DOES NOT EXIST: %@",photo.contentDMNumber,photo.referenceURL);
        }
        UIImage *photoUIImage = [UIImage imageWithContentsOfFile:imagePath];
        NSLog(@"photoUIImage size width %f height %f",photoUIImage.size.width, photoUIImage.size.height);
        */
        
        PhotoLocation *photoLocation = [[PhotoLocation alloc] init];
        photoLocation.photo=photo;
        [self.photoLocations addObject:photoLocation];
        [photoLocation release];
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    currentLoop=nil;
    [ObjectFactory setPersistentStoreFilename:@"BFCModel.db"];
    //[DataLoader loadCSVFile:nil];
    [self fetchPhotos];
    
    
    self.facebook = [[[Facebook alloc] initWithAppId:FACEBOOK_APP_ID andDelegate:self] autorelease];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"] && [defaults objectForKey:@"FBExpirationDateKey"]) {
        self.facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        self.facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
    }
    
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)dealloc
{
    [_photoLocations release];
    [_window release];
    [_tabBarController release];
    [_facebook release];
    [super dealloc];
}


@end
