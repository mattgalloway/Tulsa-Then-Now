//
//  MapViewController.h
//  BFC-iOS
//
//  Created by Brandon Pollet on 10/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#define METERS_PER_MILE 1609.344

@interface MapViewController : UIViewController <MKMapViewDelegate>{
    BOOL goneToPictureView;
}

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) IBOutlet UIButton *currentLocationButton;
@property (nonatomic, retain) IBOutlet UIButton *reframeButton;

- (void) switchToDetail:(id<MKAnnotation>) annotation;
- (IBAction) reframeButtonPressed;
- (IBAction) currentLocationButtonPressed;

@end
