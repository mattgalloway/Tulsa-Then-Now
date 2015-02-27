//
//  AppDelegate.h
//  BFC
//
//  Created by Matt Galloway on 1/22/12.
//  Copyright (c) 2012 Architactile LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect.h"

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, FBSessionDelegate,FBRequestDelegate,FBDialogDelegate> {
    CFRunLoopRef currentLoop;
    NSError *facebookPostError;
    
}

@property (strong, nonatomic) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) NSMutableArray *photoLocations;
@property (nonatomic, retain) Facebook *facebook;

-(BOOL) facebookLogin;
-(NSError *) postToFacebookWithText:(NSString *)text andImage:(UIImage *)image;

@end
