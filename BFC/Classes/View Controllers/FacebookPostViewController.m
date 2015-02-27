//
//  FacebookPostViewController.m
//  BFC
//
//  Created by Matt Galloway on 3/20/12.
//  Copyright (c) 2012 Architactile LLC. All rights reserved.
//

#import "FacebookPostViewController.h"
#import "GradientButton.h"
#import "AppDelegate.h"
#import "ModalAlert.h"

@interface FacebookPostViewController ()

@end

@implementation FacebookPostViewController
@synthesize cancelButton;
@synthesize postButton;
@synthesize postTextView;
@synthesize postImageView;
@synthesize postCardImage;
@synthesize postText;
@synthesize waitView;

- (IBAction)cancelButtonPressed:(id)sender {
    [self.view endEditing:YES];
    [self dismissModalViewControllerAnimated:YES];
}


-(void) delayedPost{
    
    AppDelegate *ap = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    
    NSError *error = [ap postToFacebookWithText:self.postTextView.text andImage:self.postCardImage];
    
    if (error!=nil) {
        [ModalAlert okWithTitle:@"Facebook Error" message:[NSString stringWithFormat:@"Unable to post to Facebook at this time. \n\nError: %@",[error localizedDescription]]];
    }
    
  
    [self dismissModalViewControllerAnimated:YES];
    self.waitView.hidden=YES;

    
}

- (IBAction)postButtonPressed:(id)sender {
    [self.view endEditing:YES];  
    [self performSelector:@selector(delayedPost) withObject:nil afterDelay:0.01];
    self.waitView.hidden=NO;
}

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
    [self.cancelButton useRedDeleteStyle];
    [self.postButton useGreenConfirmStyle];
}

- (void)viewDidUnload
{
    [self setCancelButton:nil];
    [self setPostButton:nil];
    [self setPostTextView:nil];
    [self setPostImageView:nil];
    [self setWaitView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.postImageView.image=self.postCardImage;
    self.postTextView.text=self.postText;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [cancelButton release];
    [postButton release];
    [postTextView release];
    [postImageView release];
    [postCardImage release];
    [postText release];
    [waitView release];
    [super dealloc];
}
@end
