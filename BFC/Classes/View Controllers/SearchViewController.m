//
//  SearchViewController.m
//  BFC-iOS
//
//  Created by Matt Galloway on 10/7/11.
//  Copyright 2011 Architactile LLC. All rights reserved.
//

#import "SearchViewController.h"
#import "UINavigationItem+TypewritterTitle.h"
#import "UITabBarController+HideAndShow.h"
#import "AppDelegate.h"
#import "PhotoLocation.h"
#import "Photo.h"
#import "PhotoViewController.h"

#define CELL_TITLE_LABEL    ((UILabel *)[cell viewWithTag:100])
#define CELL_DISTANCE_LABEL	((UILabel *)[cell viewWithTag:101])
#define CELL_IMAGEVIEW      ((UIImageView *)[cell viewWithTag:102])

@implementation SearchViewController
@synthesize searchBar=_searchBar;
@synthesize tableView=_tableView;
@synthesize orderedPhotoLocations=_orderedPhotoLocations;

#pragma mark - SearchBar Delegate Stuff


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar resignFirstResponder];
    [self.searchBar setShowsCancelButton:NO animated:YES];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"photo.title contains[cd] %@ or photo.desc contains[cd] %@",self.searchBar.text,self.searchBar.text];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    self.orderedPhotoLocations = [appDelegate.photoLocations filteredArrayUsingPredicate:predicate];
    
    [self.tableView reloadData];
}

-(void) searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [self.searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar resignFirstResponder];
    [self.searchBar setShowsCancelButton:NO animated:YES];

}


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
    CELL_DISTANCE_LABEL.hidden=YES;
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


#pragma mark - View lifecycle

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
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:NO];
    if (goneToPictureView) {
        [self.tabBarController showTabBar];
        goneToPictureView=NO;
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
}

-(void) viewDidLoad {
    self.orderedPhotoLocations = [NSArray arrayWithObjects: nil];
    [self.navigationItem setTypewriterTitle];
}


- (void)viewDidUnload
{
    [self setSearchBar:nil];
    [self setTableView:nil];
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
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc
{
    [_searchBar release];
    [_tableView release];
    [_orderedPhotoLocations release];
    [super dealloc];
}



@end
