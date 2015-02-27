//
//  PhotoLocation.m
//  BFC-iOS
//
//  Created by Matt Galloway on 10/7/11.
//  Copyright 2011 Architactile LLC. All rights reserved.
//

#import "PhotoLocation.h"
#import "Photo.h"

#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))

@implementation PhotoLocation 

@synthesize coordinate=_coordinate;
@synthesize distance=_distance;
@synthesize photo=_photo;
@synthesize currentLocation=_currentLocation;
@synthesize bearing;

#pragma mark - MKAnnotation Protocol Methods
- (NSString *)subtitle{
    return self.photo.date;
}

- (NSString *)title{
    return self.photo.title;
}
 
-(NSNumber *) distance {
    if (self.currentLocation==nil) return [NSNumber numberWithDouble:-1.0f];
    CLLocation *loc = [[CLLocation alloc] initWithLatitude:[self.photo.coord_lat doubleValue] longitude:[self.photo.coord_long doubleValue]];
    CLLocationDistance distanceInMeters = [loc distanceFromLocation:self.currentLocation];
    [loc release];
    return [NSNumber numberWithDouble:distanceInMeters*0.000621371192f];
}

-(float) bearing {
    if (self.currentLocation==nil) return 0.0f;
    
    CLLocation *endLocation = [[[CLLocation alloc] initWithLatitude:[self.photo.coord_lat doubleValue] longitude:[self.photo.coord_long doubleValue]] autorelease];
    
    CLLocation *northPoint = [[[CLLocation alloc] initWithLatitude:(self.currentLocation.coordinate.latitude)+.01 longitude:endLocation.coordinate.longitude] autorelease];
    
    float magA = [northPoint distanceFromLocation:self.currentLocation];
    float magB = [endLocation distanceFromLocation:self.currentLocation];
    CLLocation *startLat = [[[CLLocation alloc] initWithLatitude:self.currentLocation.coordinate.latitude longitude:0] autorelease];
    CLLocation *endLat = [[[CLLocation alloc] initWithLatitude:endLocation.coordinate.latitude longitude:0] autorelease];
    float aDotB = magA*[endLat distanceFromLocation:startLat];
    return RADIANS_TO_DEGREES(acosf(aDotB/(magA*magB)));
}

/*
-(NSString *) compassDirection {
    if (self.currentLocation==nil) return @"??";
    float bearing = [self bearing];
}
*/

- (CLLocationCoordinate2D)coordinate
{
    _coordinate.latitude = [self.photo.coord_lat doubleValue];
    _coordinate.longitude = [self.photo.coord_long doubleValue];
    return _coordinate;
}


#pragma mark - Dealloc

-(void) dealloc {
    [_distance release];
    [_photo release];
    [super dealloc];
}

@end
