//
//  YouAreHereViewController.h
//  BFC-iOS
//
//  Created by Matt Galloway on 10/7/11.
//  Copyright 2011 Architactile LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>


@class AppDelegate;

@interface YouAreHereViewController : UIViewController <CLLocationManagerDelegate,UITableViewDataSource, UITableViewDelegate> {
    
    BOOL isUpdating;
    BOOL goneToPictureView;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) CLLocationManager *locManager;
@property (nonatomic, retain) CLLocation *currentLocation;
@property (nonatomic, retain) NSMutableArray *orderedPhotoLocations;

@end
