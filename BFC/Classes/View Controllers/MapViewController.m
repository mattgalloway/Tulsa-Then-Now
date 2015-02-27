//
//  MapViewController.m
//  BFC-iOS
//
//  Created by Brandon Pollet on 10/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MapViewController.h"
#import "PhotoLocation.h"
#import "PhotoViewController.h"
#import "ObjectFactory.h"
#import "Photo.h"
#import "AppDelegate.h"
#import "UITabBarController+HideAndShow.h"
#import "UINavigationItem+TypewritterTitle.h"

@implementation MapViewController

@synthesize mapView=_mapView;
@synthesize currentLocationButton=_currentLocationButton;
@synthesize reframeButton=_reframeButton;

#pragma mark - IB Actions

-(IBAction) reframeButtonPressed {
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = 36.110289;
    zoomLocation.longitude = -95.925767;
    float distance = 6.5f;
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, distance*METERS_PER_MILE, distance*METERS_PER_MILE);
    MKCoordinateRegion adjustedRegion = [_mapView regionThatFits:viewRegion];                
    [_mapView setRegion:adjustedRegion animated:YES]; 
}

-(IBAction) currentLocationButtonPressed {

    self.mapView.showsUserLocation=!self.mapView.showsUserLocation;
    
    [self.currentLocationButton setImage:[UIImage imageNamed:(self.mapView.showsUserLocation?@"crosshair-blue.png":@"crosshair-black.png")] forState:UIControlStateNormal];
}

#pragma mark - Misc

- (void) switchToDetail:(id<MKAnnotation>) annotation {
    PhotoViewController *detailViewController = [[PhotoViewController alloc] initWithNibName:@"PhotoView" bundle:nil];
    [detailViewController setPhotoLocationTo:(PhotoLocation *)annotation];
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
    [self.tabBarController hideTabBar];
    goneToPictureView=YES;
}


- (void)plotPhotoLocation:(NSArray *)photoLocations {
    
    for (id<MKAnnotation> annotation in _mapView.annotations) {
        [_mapView removeAnnotation:annotation];
    }
    
    for (PhotoLocation *photoLocation in photoLocations) {
        //CLLocationCoordinate2D coordinate = photoLocation.coordinate; 
        //NSLog(@"%@ %f %f ",photoLocation.photo.title, coordinate.longitude, coordinate.latitude);
        [self.mapView addAnnotation:photoLocation];    
    }
}

#pragma mark - MapKit Delegate Methods

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    [self switchToDetail:view.annotation];
}

- (MKAnnotationView *)mapView:(MKMapView *)map viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    // try to dequeue an existing pin view first
    static NSString* AnnotationIdentifier = @"annotationIdentifier";
    MKPinAnnotationView* pinView = (MKPinAnnotationView *)
    [self.mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationIdentifier];
    if (!pinView)
    {
        // if an existing pin view was not available, create one
        MKPinAnnotationView* customPinView = [[[MKPinAnnotationView alloc]
                                               initWithAnnotation:annotation reuseIdentifier:AnnotationIdentifier] autorelease];
        customPinView.pinColor = MKPinAnnotationColorRed;
        customPinView.animatesDrop = NO;
        customPinView.canShowCallout = YES;        
        UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        customPinView.rightCalloutAccessoryView = rightButton;

        /*
        PhotoLocation *photoLocation = (PhotoLocation *)annotation;
        NSString *imagePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@",photoLocation.photo.contentDMNumber] ofType:@"jpg" inDirectory:@"BFC_Selected_Images.bundle"];
        UIImage *photoUIImage = [UIImage imageWithContentsOfFile:imagePath];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:photoUIImage];
        imageView.frame=CGRectMake(0.0f, 0.0f, 60.0f, 60.0f);
        imageView.backgroundColor = [UIColor blackColor];
        customPinView.leftCalloutAccessoryView = imageView;
        */
        
        return customPinView;
    } else {
        pinView.annotation = annotation;
    }
    return pinView;
}
 

-(void) mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    [self.mapView setCenterCoordinate: userLocation.location.coordinate
                             animated: YES];
}

#pragma mark - View lifecycle, etc.

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self reframeButtonPressed];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self plotPhotoLocation:appDelegate.photoLocations];  
    goneToPictureView=NO;
    
    [self.navigationItem setTypewriterTitle];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.mapView = nil;
}
-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];    
}

- (void)viewWillAppear:(BOOL)animated {  
    _mapView.showsUserLocation = NO;
    [_mapView setUserTrackingMode:MKUserTrackingModeNone];
    if (goneToPictureView) {
        [self.tabBarController showTabBar];
        goneToPictureView=NO;
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.mapView.showsUserLocation) {
        [self currentLocationButtonPressed];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc
{
    [_mapView release];
    [_reframeButton release];
    [_currentLocationButton release];
    [super dealloc];
}


@end
