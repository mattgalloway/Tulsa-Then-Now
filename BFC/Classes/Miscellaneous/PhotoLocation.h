//
//  PhotoLocation.h
//  BFC-iOS
//
//  Created by Matt Galloway on 10/7/11.
//  Copyright 2011 Architactile LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@class Photo;

@interface PhotoLocation : NSObject <MKAnnotation> {
    
}

@property (nonatomic, retain)   Photo *photo;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain)   NSNumber *distance; // (in miles)
@property (nonatomic, retain) CLLocation *currentLocation;
@property (readonly) float bearing;

@end
