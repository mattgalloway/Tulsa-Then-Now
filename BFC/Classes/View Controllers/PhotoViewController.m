//
//  PhotoViewController.m
//  BFC-iOS
//
//  Created by Matt Galloway on 10/8/11.
//  Copyright 2011 Architactile LLC. All rights reserved.
//

#import <Twitter/Twitter.h>
#import "PhotoViewController.h"
#import "PhotoLocation.h"
#import "Photo.h"
#import "GradientButton.h"
#import "UILabel+VerticalAlignment.h"
#import "UINavigationItem+TypewritterTitle.h"
#import "PostCardTemplate.h"
#import "ModalAlert.h"
#import "AppDelegate.h"
#import "FacebookPostViewController.h"


#define PUSHED_ALPHA 1.0f
#define UNPUSHED_ALPHA 0.7f


@implementation PhotoViewController

@synthesize selectedPhoto=_selectedPhoto;
@synthesize photoImage=_photoImage;
@synthesize scrollView=_scrollView;
@synthesize backButton=_backButton;
@synthesize infoButton=_infoButton;
@synthesize berylOGramButton=_berylOGramButton;
@synthesize mapButton=_mapButton;
@synthesize photoTileLabel=_photoTileLabel;
@synthesize contentView=_contentView;
@synthesize mapView=_mapView;
@synthesize infoView=_infoView;
@synthesize photoButton=_photoButton;
@synthesize bogView=_bogView;
@synthesize bogDeliveryMethodView = _bogDeliveryMethodView;
@synthesize infoWebView=_infoWebView;
@synthesize mapMapView=_mapMapView;
@synthesize currentLocationButton=_currentLocationButton;
@synthesize reframeButton=_reframeButton;
@synthesize mapAppButton=_mapAppButton;
@synthesize bogPhotoOnlyButton=_bogPhotoOnlyButton;
@synthesize bogThenAndNowButton=_bogThenAndNowButton;
@synthesize emailButton = _emailButton;
@synthesize textButton = _textButton;
@synthesize tweetButton = _tweetButton;
@synthesize facebookButton = _facebookButton;
@synthesize imagePickerController=_imagePickerController;
@synthesize cameraOverlayView=_cameraOverlayView;
@synthesize photoOverlayView=_photoOverlayView;
@synthesize thenAndNowPushedActivityIndicator=_thenAndNowPushedActivityIndicator;
@synthesize photoForPhotoOverlayView=_photoForPhotoOverlayView;
@synthesize topScreenView=_topScreenView;
@synthesize bottomScreenView=_bottomScreenView;
@synthesize workingScreen=_workingScreen;
@synthesize nowImage=_nowImage;

#pragma mark - Photo Size Calc

-(CGSize) bestSizeFor:(UIImage *)image toFitInto:(UIImageView *)imageView {
    
    CGFloat widthScale = image.size.width/imageView.frame.size.width;
    CGFloat heightScale = image.size.height/imageView.frame.size.height;
    
    CGFloat scale;
    CGFloat height, width;
    
    if (widthScale>heightScale) {
        scale = widthScale;
    } else {
        scale =heightScale;
    }
    width = image.size.width/scale;
    height = image.size.height/scale;

    //NSLog(@"To fit (%f, %f) into (%f, %f) may we suggest (%f, %f)",image.size.width,image.size.height,imageView.frame.size.width,imageView.frame.size.height,width,height);

    return CGSizeMake(width, height);
}

#pragma mark - Set Photo

-(void) setPhotoLocationTo:(PhotoLocation *)photoLocation {
    self.selectedPhoto = photoLocation;
}

#pragma mark - Flip View
-(void) flipContentTo:(UIView *) toView flipForward:(BOOL)flipForward {
    
    if (toView.superview == self.contentView) return;

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1.0];
    [UIView setAnimationTransition:(flipForward? UIViewAnimationTransitionFlipFromLeft:UIViewAnimationTransitionFlipFromRight)
                           forView:self.contentView
                             cache:YES];
    for (UIView *view in [self.contentView subviews]) {
        [view removeFromSuperview];
    }
    [self.contentView addSubview:toView];
    [UIView commitAnimations];
}

#pragma mark - IB Hooks

- (IBAction)emailButtonPressed:(id)sender {
    if (self.nowImage==nil) {
        [self emailSinglePhotoImage];
    } else {
        [self emailThenAndNowWithNowImage:self.nowImage];
    }
}

- (IBAction)textButtonPressed:(id)sender {

}

- (IBAction)tweetButtonPressed:(id)sender {
    
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    NSArray *verComponents = [currSysVer componentsSeparatedByString:@"."];
    if ([[verComponents objectAtIndex:0] intValue] < 5){
        
        [ModalAlert okWithTitle:@"Feature Not Available" message:@"Sorry but the Tweet feature is only available on iOS5 and higher."];
    } else {
        
        UIImage *postCard=nil;
        if (self.nowImage==nil) {
            postCard=[self makeNowOnlyPostCard];
        } else {
            postCard=[self makeThenAndNowPostCardWith:self.nowImage];
        }
        
        // Create the view controller
        TWTweetComposeViewController *twitter = [[TWTweetComposeViewController alloc] init];
        
        // Optional: set an image, url and initial text
        [twitter addImage:postCard];
        //[twitter addURL:[NSURL URLWithString:[NSString stringWithString:@"http://iOSDeveloperTips.com/"]]];
        [twitter setInitialText:[NSString stringWithFormat:@"Tulsa Then & Now: %@ ",self.selectedPhoto.photo.title] ];
        
        // Show the controller
        [self presentModalViewController:twitter animated:YES];
        
        // Called when the tweet dialog has been closed
        twitter.completionHandler = ^(TWTweetComposeViewControllerResult result) 
        {
            
            /*
             NSString *title = @"Tweet Status";
             NSString *msg; 
             
             if (result == TWTweetComposeViewControllerResultCancelled)
             msg = @"Tweet canceled.";
             else if (result == TWTweetComposeViewControllerResultDone)
             msg = @"Tweet sent.";
             
             // Show alert to see how things went...
             UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
             [alertView show];
             */
            
            // Dismiss the controller
            [self dismissModalViewControllerAnimated:YES];
        };
    }
}

- (IBAction)facebookButtonPressed:(id)sender {
    //[ModalAlert okWithTitle:@"Not Implemented" message:@"Sorry but the Facebook feature is not yet implemented."];
    AppDelegate *ad = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    if (![ad facebookLogin]) {
        [ModalAlert okWithTitle:@"Facebook Not Available" message:@"Sorry, but you have to give Tulsa Then & Now access to Facebook if you want to post to your wall."];
    } else {
        
        UIImage *postCard=nil;
        if (self.nowImage==nil) {
            postCard=[self makeNowOnlyPostCard];
        } else {
            postCard=[self makeThenAndNowPostCardWith:self.nowImage];
        }
        
        FacebookPostViewController *fpvc = [[FacebookPostViewController alloc] initWithNibName:@"FacebookPostView" bundle:nil];
        fpvc.postCardImage=postCard;
        fpvc.postText = [NSString stringWithFormat:@"Tulsa Then & Now: %@ \n\nThis postcard was created with the Tulsa City-County Library's Tulsa Then & Now app for iPhone. \n\nDownload it free in the App Store: http://itunes.com/apps/tulsacitycountylibrary",self.selectedPhoto.photo.title];
        
        [self presentModalViewController:fpvc animated:YES];
        [fpvc release];
    }
}

-(void) colorButtons:(id) sender {
    GradientButton *button=sender;
    [self.backButton setEnabled:YES];
    [self.photoButton setEnabled:YES]; 
    [self.mapButton setEnabled:YES]; 
    [self.infoButton setEnabled:YES]; 
    [self.berylOGramButton setEnabled:YES]; 
    [button  setEnabled:NO];
    //[button setAlpha:PUSHED_ALPHA];
}

-(IBAction) bogPhotoOnlyButtonPressed:(id) sender {
    self.nowImage=nil;
    [self flipContentTo:self.bogDeliveryMethodView flipForward:YES];
}

-(void) getBOGNowPhoto {   
	self.imagePickerController = [[[UIImagePickerController alloc] init] autorelease];
    self.imagePickerController.sourceType =  UIImagePickerControllerSourceTypeCamera;
    self.imagePickerController.allowsEditing = YES;
	self.imagePickerController.delegate = self;
    self.imagePickerController.cameraOverlayView=self.cameraOverlayView;
    self.imagePickerController.showsCameraControls=NO;
    [self presentModalViewController:self.imagePickerController animated:NO];	
}

-(IBAction) snapPhoto:(id) sender {
    [self.imagePickerController takePicture];
}

-(IBAction) cancelPhoto:(id) sender {
    self.workingScreen.hidden=YES;
    [self.thenAndNowPushedActivityIndicator stopAnimating];
    [self dismissModalViewControllerAnimated:YES];
    self.imagePickerController = nil;
}

-(IBAction) overlayToggle:(id) sender {
    self.photoOverlayView.hidden = !self.photoOverlayView.hidden;
}

-(IBAction) bogThenAndNowButtonPressed:(id) sender {   
    self.nowImage=nil;
    self.workingScreen.hidden=NO;
    [self.thenAndNowPushedActivityIndicator startAnimating];
    [self performSelector:@selector(getBOGNowPhoto) withObject:nil afterDelay:0.05];
}


-(IBAction) mapAppButtonPressed {
    NSString *addrurl = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%@, %@",self.selectedPhoto.photo.coord_lat,self.selectedPhoto.photo.coord_long];
    NSURL *url = [NSURL URLWithString:[addrurl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [[UIApplication sharedApplication] openURL:url];
}

-(IBAction) reframeButtonPressed {
    [self reframeMap];
}

-(IBAction) currentLocationButtonPressed {
    self.mapMapView.showsUserLocation=!self.mapMapView.showsUserLocation;
    [self.currentLocationButton setImage:[UIImage imageNamed:(self.mapMapView.showsUserLocation?@"crosshair-blue.png":@"crosshair-black.png")] forState:UIControlStateNormal];
}

-(IBAction) doneButtonPressed:(id) sender {
    [self colorButtons:sender];
    [self.navigationController popViewControllerAnimated:YES];
    if (self.mapMapView.showsUserLocation) [self currentLocationButtonPressed];
}

-(IBAction) photoButtonPressed:(id) sender {
    [self colorButtons:sender];
    [self flipContentTo:self.scrollView flipForward:NO];
    if (self.mapMapView.showsUserLocation) [self currentLocationButtonPressed];
}

-(IBAction) mapButtonPressed:(id) sender {
    [self colorButtons:sender];

    [self reframeMap];
    [self flipContentTo:self.mapView flipForward:YES];
}

-(IBAction) infoButtonPressed:(id) sender {
    [self colorButtons:sender];

    [self flipContentTo:self.infoView flipForward:YES];
    if (self.mapMapView.showsUserLocation) [self currentLocationButtonPressed];
}

-(IBAction) sendButtonPressed:(id) sender {
    [self colorButtons:sender];

    [self flipContentTo:self.bogView flipForward:YES];
    if (self.mapMapView.showsUserLocation) [self currentLocationButtonPressed];
}

#pragma mark - UIWebViewDelegate

-(BOOL) webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType {
    if ( inType == UIWebViewNavigationTypeLinkClicked ) {
        [[UIApplication sharedApplication] openURL:[inRequest URL]];
        return NO;
    }
    return YES;
}

#pragma mark - UIScrollView Delegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.photoImage;
}

#pragma mark - Text Message Delegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    
}

#pragma mark - Mail Compose Delegate Stuff

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Map Centering 

-(void) reframeMap {
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = [self.selectedPhoto.photo.coord_lat doubleValue];
    zoomLocation.longitude = [self.selectedPhoto.photo.coord_long doubleValue];
    float distance = 0.5f;
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, distance*METERS_PER_MILE, distance*METERS_PER_MILE);
    MKCoordinateRegion adjustedRegion = [_mapMapView regionThatFits:viewRegion];                
    [_mapMapView setRegion:adjustedRegion animated:YES]; 
}

-(UIImage *) makeThenAndNowPostCardWith:(UIImage *)nowPhoto {
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@",self.selectedPhoto.photo.contentDMNumber] ofType:@"jpg" inDirectory:@"BFC_Selected_Images.bundle"];
    UIImage *thenPhoto = [UIImage imageWithContentsOfFile:imagePath];
    
    CGFloat widthScale = thenPhoto.size.width/(nowPhoto.size.width);
    CGFloat heightScale = thenPhoto.size.height/(nowPhoto.size.height);
    
    CGFloat x,y,scale;
    CGFloat height, width;
    
    if (widthScale>heightScale) {
        scale = widthScale;
        width = nowPhoto.size.width*scale;
        height = nowPhoto.size.height*scale;
        x = 0.0f;
        y = (height-thenPhoto.size.height)/2.0f;
    } else {
        scale =heightScale;
        width = nowPhoto.size.width*scale;
        height = nowPhoto.size.height*scale;
        y = 0.0f;
        x = (width-thenPhoto.size.width)/2.0f;
    }
    CGRect drawRect = CGRectMake(-x, -y, width, height);
    
    UIGraphicsBeginImageContext(CGSizeMake(thenPhoto.size.width, thenPhoto.size.height));
    [nowPhoto drawInRect:drawRect];
    UIImage *croppedNowImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndPDFContext();
    
    PostCardTemplate *postCardTemplate = [[PostCardTemplate alloc] init];
    UINib *postCardTemplateNIB = [UINib nibWithNibName:@"ThenAndNowTemplate" bundle:nil];
    [postCardTemplateNIB instantiateWithOwner:postCardTemplate options:nil];
    
//    CGPoint thenCenter = postCardTemplate.thenPhotoFrameView.center;
    CGPoint thenOrigin = postCardTemplate.thenPhotoFrameView.frame.origin;
    CGSize thenSize = postCardTemplate.thenPhotoFrameView.frame.size;
    CGSize bestPhotoSize = [self bestSizeFor:thenPhoto toFitInto:postCardTemplate.thenPhotoView];
    postCardTemplate.thenPhotoView.image = thenPhoto;
    
    postCardTemplate.thenPhotoFrameView.frame = CGRectMake(
                                                           thenOrigin.x,
                                                           thenOrigin.y+thenSize.height-(bestPhotoSize.height+55),
                                                           bestPhotoSize.width+52,
                                                           bestPhotoSize.height+55);
    //postCardTemplate.thenPhotoFrameView.center=thenCenter;
    
    //CGPoint nowCenter = postCardTemplate.nowPhotoFrameView.center;
    CGPoint nowOrigin = postCardTemplate.nowPhotoFrameView.frame.origin;
    CGSize nowSize = postCardTemplate.nowPhotoFrameView.frame.size;
    bestPhotoSize = [self bestSizeFor:croppedNowImage toFitInto:postCardTemplate.nowPhotoView];
    postCardTemplate.nowPhotoView.image = croppedNowImage;
    postCardTemplate.nowPhotoFrameView.frame = CGRectMake(nowOrigin.x+nowSize.width-(bestPhotoSize.width+52),
                                                          nowOrigin.y,
                                                          bestPhotoSize.width+52,
                                                          bestPhotoSize.height+55);
    //postCardTemplate.nowPhotoFrameView.center=nowCenter;
    
    postCardTemplate.titleTextView.text=[NSString stringWithFormat:@"               %@",self.selectedPhoto.photo.title];
    postCardTemplate.descriptionTextView.text=[NSString stringWithFormat:@"                                %@",self.selectedPhoto.photo.desc];
    
    UIGraphicsBeginImageContext(postCardTemplate.postCardView.frame.size);
    [postCardTemplate.postCardView.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *photoInFrameImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return photoInFrameImage;
}

-(void) emailThenAndNowWithNowImage:(UIImage *) nowPhoto {
    if ([MFMailComposeViewController canSendMail])
	{
		MFMailComposeViewController *mcvc = [[[MFMailComposeViewController alloc] init] autorelease];
		mcvc.mailComposeDelegate = self;
        [mcvc setSubject:[NSString stringWithFormat:@"Beryl-O-Gram: %@",self.selectedPhoto.photo.title]];
        NSString *body = [NSString stringWithFormat:@"<p>Tulsa Then & Now: %@ </p><p>This postcard was created with the Tulsa City-County Library's Tulsa Then & Now app for iPhone.</p><p>Download it free in the App Store: http://itunes.com/apps/tulsacitycountylibrary</p>",self.selectedPhoto.photo.title];
        [mcvc setMessageBody:body isHTML:YES];
        
        [mcvc addAttachmentData:UIImageJPEGRepresentation([self makeThenAndNowPostCardWith:nowPhoto], 1.0f) mimeType:@"image/jpeg" fileName:@"then.jpg"];
        
		[self presentModalViewController:mcvc animated:YES];
	}
    self.workingScreen.hidden=YES;
    [self.thenAndNowPushedActivityIndicator stopAnimating];
}

-(UIImage *) makeNowOnlyPostCard {
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@",self.selectedPhoto.photo.contentDMNumber] ofType:@"jpg" inDirectory:@"BFC_Selected_Images.bundle"];
    UIImage *thenPhoto = [UIImage imageWithContentsOfFile:imagePath];
    
    PostCardTemplate *postCardTemplate = [[PostCardTemplate alloc] init];
    UINib *postCardTemplateNIB = [UINib nibWithNibName:@"SinglePhotoTemplate" bundle:nil];
    [postCardTemplateNIB instantiateWithOwner:postCardTemplate options:nil];
    
    CGPoint thenCenter = postCardTemplate.thenPhotoFrameView.center;
    CGSize bestPhotoSize = [self bestSizeFor:thenPhoto toFitInto:postCardTemplate.thenPhotoView];
    postCardTemplate.thenPhotoView.image = thenPhoto;
    postCardTemplate.thenPhotoFrameView.frame = CGRectMake(0,0,bestPhotoSize.width+52,bestPhotoSize.height+55);
    postCardTemplate.thenPhotoFrameView.center=thenCenter;
    
    postCardTemplate.titleTextView.text=self.selectedPhoto.photo.title;
    postCardTemplate.descriptionTextView.text=self.selectedPhoto.photo.desc;
    
    UIGraphicsBeginImageContext(postCardTemplate.postCardView.frame.size);
    [postCardTemplate.postCardView.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *photoInFrameImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return photoInFrameImage;
}

-(void) emailSinglePhotoImage {
    if ([MFMailComposeViewController canSendMail])
	{
		MFMailComposeViewController *mcvc = [[[MFMailComposeViewController alloc] init] autorelease];
		mcvc.mailComposeDelegate = self;
        [mcvc setSubject:[NSString stringWithFormat:@"Beryl-O-Gram: %@",self.selectedPhoto.photo.title]];
        NSString *body = [NSString stringWithFormat:@"<p>Tulsa Then & Now: %@ </p><p>This postcard was created with the Tulsa City-County Library's Tulsa Then & Now app for iPhone.</p><p>Download it free in the App Store: http://itunes.com/apps/tulsacitycountylibrary</p>",self.selectedPhoto.photo.title];
        [mcvc setMessageBody:body isHTML:YES];

        [mcvc addAttachmentData:UIImageJPEGRepresentation([self makeNowOnlyPostCard], 1.0f) mimeType:@"image/jpeg" fileName:@"then.jpg"];
        
		[self presentModalViewController:mcvc animated:YES];
	}
    self.workingScreen.hidden=YES;
    [self.thenAndNowPushedActivityIndicator stopAnimating];
}


#pragma mark - Camera Delegate Methods

-(void) delayedFlip {
    [self flipContentTo:self.bogDeliveryMethodView flipForward:YES];
    self.workingScreen.hidden=YES;
    [self.thenAndNowPushedActivityIndicator stopAnimating];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    if (!image) 
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    [self dismissModalViewControllerAnimated:YES];
    self.imagePickerController = nil;
    self.nowImage=image;
    [self performSelector:@selector(delayedFlip) withObject:nil afterDelay:0.5];
}

// Dismiss picker
- (void) imagePickerControllerDidCancel: (UIImagePickerController *)picker
{
    [self cancelPhoto:nil];
}


#pragma mark - MapKit Delegate Methods

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
}

- (MKAnnotationView *)mapView:(MKMapView *)map viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    // try to dequeue an existing pin view first
    static NSString* AnnotationIdentifier = @"annotationIdentifier2";
    MKPinAnnotationView* pinView = (MKPinAnnotationView *)
    [map dequeueReusableAnnotationViewWithIdentifier:AnnotationIdentifier];
    if (!pinView)
    {
        // if an existing pin view was not available, create one
        MKPinAnnotationView* customPinView = [[[MKPinAnnotationView alloc]
                                               initWithAnnotation:annotation reuseIdentifier:AnnotationIdentifier] autorelease];
        customPinView.pinColor = MKPinAnnotationColorRed;
        customPinView.animatesDrop = NO;
        customPinView.canShowCallout = YES;        
        //UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        //customPinView.rightCalloutAccessoryView = rightButton;
        
        return customPinView;
    } else {
        pinView.annotation = annotation;
    }
    return pinView;
}


-(void) mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    [mapView setCenterCoordinate: userLocation.location.coordinate
                             animated: YES];
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    firstLoad=YES;
    self.workingScreen.hidden=YES;
    [self.navigationItem setTypewriterTitle];
    
    [self.emailButton useBlackStyle];
    [self.textButton useBlackStyle];
    [self.tweetButton useBlackStyle];
    [self.facebookButton useBlackStyle];
    
}

- (void)viewDidUnload
{
    [self setEmailButton:nil];
    [self setTextButton:nil];
    [self setTweetButton:nil];
    [self setFacebookButton:nil];
    [self setBogDeliveryMethodView:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (firstLoad) {
        
        firstLoad=NO;

        
        [self.backButton useWhiteStyle];
        [self.photoButton useWhiteStyle];
        [self.mapButton useWhiteStyle];
        [self.infoButton useWhiteStyle];
        [self.berylOGramButton useWhiteStyle];
        [self.bogPhotoOnlyButton useWhiteStyle];
        [self.bogThenAndNowButton useWhiteStyle];
        [self colorButtons:self.photoButton];
        
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            self.bogThenAndNowButton.enabled=NO;
            self.bogThenAndNowButton.alpha=0.30;
        }
        
        
        self.photoTileLabel.text=self.selectedPhoto.photo.title;
        [self.photoTileLabel setVerticalAlignmentWithMaxFrame:self.photoTileLabel.frame withText:self.photoTileLabel.text usingVerticalAlign:VerticalAlignmentBottom];
        
        NSString *imagePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@",self.selectedPhoto.photo.contentDMNumber] ofType:@"jpg" inDirectory:@"BFC_Selected_Images.bundle"];
        UIImage *photoUIImage = [UIImage imageWithContentsOfFile:imagePath];
        
        float widthScale = photoUIImage.size.width/(self.scrollView.frame.size.width-self.scrollView.contentInset.left-self.scrollView.contentInset.right);
        float heightScale = photoUIImage.size.height/(self.scrollView.frame.size.height-self.scrollView.contentInset.top-self.scrollView.contentInset.bottom);
        
        float scale; 
        
        if (widthScale>heightScale) {
            scale = widthScale;
        } else {
            scale =heightScale;
        }
        
        self.photoImage.frame = CGRectMake(0.0f,0.0f,photoUIImage.size.width,photoUIImage.size.height);
        
        
        self.scrollView.contentSize = self.photoImage.frame.size;
        self.scrollView.zoomScale=1.0f/scale;
        self.scrollView.minimumZoomScale=1.0f/scale;
        self.scrollView.maximumZoomScale=7.0f/scale;
        
        [self.photoImage setImage:photoUIImage];
        
        
        // Set up overlay view for Now photo
        
        widthScale = photoUIImage.size.width/(self.photoOverlayView.frame.size.width);
        heightScale = photoUIImage.size.height/(self.photoOverlayView.frame.size.height);
        
        CGFloat x,y;
        CGFloat height, width;
        
        if (widthScale>heightScale) {
            scale = widthScale;
            width = photoUIImage.size.width/scale;
            height = photoUIImage.size.height/scale;
            x = 0.0f;
            y = (self.photoOverlayView.frame.size.height-height)/2.0f;
            self.topScreenView.frame = CGRectMake(0.0f, 0.0f, self.photoOverlayView.frame.size.width,y);
            self.bottomScreenView.frame = CGRectMake(0.0f, y+height, self.photoOverlayView.frame.size.width,y);
            
        } else {
            scale =heightScale;
            width = photoUIImage.size.width/scale;
            height = photoUIImage.size.height/scale;
            y = 0.0f;
            x = (self.photoOverlayView.frame.size.width-width)/2.0f;
            self.topScreenView.frame = CGRectMake(0.0f, 0.0f, x, self.photoOverlayView.frame.size.height);
            self.bottomScreenView.frame = CGRectMake(x+width, 0.0f, x, self.photoOverlayView.frame.size.height);
        }
        self.photoForPhotoOverlayView.frame = CGRectMake(x, y, width, height);
        
        [self.photoForPhotoOverlayView setImage:photoUIImage];
        
        // Set up info view text in HTML for Web View
        
        NSMutableString *html = [NSMutableString stringWithCapacity:500];
        
        [html appendString:@"<html><head>\n"];
        
        [html appendString:@"<style type=\"text/css\">\n"];
        [html appendString:@"body {background: #FFFFFF;"];
        [html appendString:@"font-family:\"American Typewriter\";"];
        [html appendString:@"color:#000000;"];
        [html appendString:@" }\n"];
        
        [html appendString:@"</style>\n"];
        [html appendString:@"</head><body>\n"];
        
        [html appendFormat:@"<b><u>%@</u></b> %@</br></br>\n",@"Title:",self.selectedPhoto.photo.title];
        if ([self.selectedPhoto.photo.date length]>0) 
            [html appendFormat:@"<b><u>%@</u></b> %@</br></br>\n",@"Date:",self.selectedPhoto.photo.date];
        if ([self.selectedPhoto.photo.desc length]>0) 
            [html appendFormat:@"<b><u>%@</u></b> %@</br></br>\n",@"Description:",self.selectedPhoto.photo.desc];
        if ([self.selectedPhoto.photo.address length]>0) 
            [html appendFormat:@"<b><u>%@</u></b> %@, Tulsa, Oklahoma</br></br>\n",@"Address:",self.selectedPhoto.photo.address];
        [html appendFormat:@"<b><u>%@</u></b> <br/><a href=\"%@\">Tulsa City-County Library Website</a></br></br>\n",@"Web Link:",self.selectedPhoto.photo.referenceURL];
        [html appendFormat:@"<b><u>%@</u></b> %@</br></br>\n",@"Digital Publisher:",self.selectedPhoto.photo.digitalPublisher];
        [html appendFormat:@"<b><u>%@</u></b> %@</br></br>\n",@"Rights:",self.selectedPhoto.photo.rights];
        [html appendFormat:@"<b><u>%@</u></b> %@</br></br>\n",@"Contributors:",self.selectedPhoto.photo.contributors];

        [html appendFormat:@"<b><u>%@</u></b> %@</br></br>\n",@"ContentDM Number:",self.selectedPhoto.photo.contentDMNumber];
        [html appendFormat:@"<b><u>%@</u></b> %@</br></br>\n",@"Relation:",self.selectedPhoto.photo.relation];
        
        [html appendString:@"\n</body></html>\n"];
        
        //NSLog(@"%@",html);
        
        [self.infoWebView loadHTMLString:html baseURL:nil];
        
        [self.mapMapView addAnnotation:self.selectedPhoto]; 
        
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [_photoImage release];
    [_selectedPhoto release];
    [_scrollView release];
    [_backButton release];
    [_infoButton release];
    [_berylOGramButton release];
    [_mapButton release];
    [_photoTileLabel release];
    [_contentView release];
    [_mapView release];
    [_infoView release];
    [_photoButton release];
    [_bogView release];
    [_infoWebView release];
    [_mapMapView release];
    [_currentLocationButton release];
    [_reframeButton release];
    [_mapAppButton release];
    [_bogPhotoOnlyButton release];
    [_bogThenAndNowButton release];
    [_imagePickerController release];
    [_cameraOverlayView release];
    [_photoOverlayView release];
    [_thenAndNowPushedActivityIndicator release];
    [_photoForPhotoOverlayView release];
    [_topScreenView release];
    [_bottomScreenView release];
    [_workingScreen release];
    [_nowImage release];
    [_emailButton release];
    [_textButton release];
    [_tweetButton release];
    [_facebookButton release];
    [_bogDeliveryMethodView release];
    [super dealloc];
}


@end
