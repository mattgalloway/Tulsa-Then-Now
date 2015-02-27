//
//  NowPhotoViewController.m
//  BFC
//
//  Created by Matt Galloway on 2/5/12.
//  Copyright (c) 2012 Architactile LLC. All rights reserved.
//

#import "NowPhotoViewController.h"
#import "UINavigationItem+TypewritterTitle.h"


@implementation NowPhotoViewController

@synthesize imagePickerController=_imagePickerController;

#pragma mark - View lifecycle

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	self.imagePickerController = [[[UIImagePickerController alloc] init] autorelease];
    self.imagePickerController.sourceType =  UIImagePickerControllerSourceTypeCamera;
    self.imagePickerController.allowsEditing = NO;
	//self.imagePickerController.delegate = self;
    
    [self presentModalViewController:self.imagePickerController animated:NO];	
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(void) viewDidLoad {
    [super viewDidLoad];
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
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
    [_imagePickerController release];
    [super dealloc];
}

@end
