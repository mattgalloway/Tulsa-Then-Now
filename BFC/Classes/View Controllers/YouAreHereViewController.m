//
//  YouAreHereViewController.m
//  BFC-iOS
//
//  Created by Matt Galloway on 10/7/11.
//  Copyright 2011 Architactile LLC. All rights reserved.
//

#import "YouAreHereViewController.h"
#import "PhotoLocation.h"
#import "PhotoViewController.h"
#import "AppDelegate.h"
#import "Photo.h"
#import "UITabBarController+HideAndShow.h"
#import "UINavigationItem+TypewritterTitle.h"

#define CELL_TITLE_LABEL    ((UILabel *)[cell viewWithTag:100])
#define CELL_DISTANCE_LABEL	((UILabel *)[cell viewWithTag:101])
#define CELL_IMAGEVIEW      ((UIImageView *)[cell viewWithTag:102])

@implementation YouAreHereViewController

@synthesize tableView=_tableView;
@synthesize locManager=_locManager;
@synthesize currentLocation=_currentLocation;
@synthesize orderedPhotoLocations=_orderedPhotoLocations;

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.orderedPhotoLocations count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"YouAreHereCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"ListCellView" owner:self options:nil] lastObject];
    }
    
    PhotoLocation *photoLocation = (PhotoLocation *) [self.orderedPhotoLocations objectAtIndex:indexPath.row];
    
    [CELL_TITLE_LABEL setText:photoLocation.photo.title];
    if ([photoLocation.distance floatValue]<0) {
        CELL_DISTANCE_LABEL.hidden=YES;
    } else {
        CELL_DISTANCE_LABEL.hidden=NO;
   // [CELL_DISTANCE_LABEL setText:[NSString stringWithFormat:@"(%.2f miles) %f",[photoLocation.distance floatValue],photoLocation.bearing]];
        [CELL_DISTANCE_LABEL setText:[NSString stringWithFormat:@"(%.2f miles)",[photoLocation.distance floatValue]]];
    }    
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@",photoLocation.photo.contentDMNumber] ofType:@"jpg" inDirectory:@"BFC_Selected_Images.bundle"];
    
    [CELL_IMAGEVIEW setImage:[UIImage imageWithContentsOfFile:imagePath]];
     
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoLocation *photoLocation = (PhotoLocation *) [self.orderedPhotoLocations objectAtIndex:indexPath.row];
    PhotoViewController *detailViewController = [[PhotoViewController alloc] initWithNibName:@"PhotoView" bundle:nil];
    [detailViewController setPhotoLocationTo:photoLocation];
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
    [self.tabBarController hideTabBar];
    goneToPictureView=YES;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 160.0f;
}


#pragma mark - Core Location Delegate Stuff

-(void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {

    if (!isUpdating) {
        isUpdating=YES;
        self.currentLocation=newLocation;
        for (PhotoLocation *photoLocation in self.orderedPhotoLocations){
            photoLocation.currentLocation=self.currentLocation;
        }
        
        NSSortDescriptor *sortByDistance = [NSSortDescriptor sortDescriptorWithKey:@"distance" ascending:YES];
        
        [self.orderedPhotoLocations sortUsingDescriptors:[NSArray arrayWithObject:sortByDistance]];
        [self.tableView reloadData];
    }
    isUpdating=NO;
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

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    isUpdating=NO;
    if (![CLLocationManager locationServicesEnabled]) {
        self.locManager = nil;
        self.currentLocation = nil;
    } else {
        self.locManager = [[[CLLocationManager alloc] init] autorelease];
        self.locManager.delegate = self;
        self.locManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locManager.distanceFilter = 5.0f; // in meters
        [self.locManager startUpdatingLocation];
    }
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:NO];
    if (goneToPictureView) {
        [self.tabBarController showTabBar];
        goneToPictureView=NO;
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.locManager!=nil) {
        [self.locManager stopUpdatingLocation];
    }
}

-(void) viewDidLoad {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.orderedPhotoLocations = appDelegate.photoLocations;
    goneToPictureView=NO;
    [self.navigationItem setTypewriterTitle];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
}

- (void)dealloc
{
    [_tableView release];
    [_locManager release];
    [_currentLocation release];
    [_orderedPhotoLocations release];
    [super dealloc];
}

@end
