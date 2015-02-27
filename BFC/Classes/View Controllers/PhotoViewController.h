//
//  PhotoViewController.h
//  BFC-iOS
//
//  Created by Matt Galloway on 10/8/11.
//  Copyright 2011 Architactile LLC. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import <MapKit/MapKit.h>
#import <UIKit/UIKit.h>

@class PhotoLocation;
@class GradientButton;

#define METERS_PER_MILE 1609.344

@interface PhotoViewController : UIViewController<UIScrollViewDelegate,MKMapViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate,UIWebViewDelegate> {
    
    BOOL firstLoad;
    
}

@property (nonatomic, retain) IBOutlet UIImageView *photoImage;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UILabel          *photoTileLabel;
@property (nonatomic, retain) IBOutlet GradientButton   *backButton;
@property (nonatomic, retain) IBOutlet GradientButton   *infoButton;
@property (nonatomic, retain) IBOutlet GradientButton   *berylOGramButton;
@property (nonatomic, retain) IBOutlet GradientButton   *mapButton;
@property (nonatomic, retain) IBOutlet GradientButton   *photoButton;
@property (nonatomic, retain) IBOutlet GradientButton   *bogPhotoOnlyButton;
@property (nonatomic, retain) IBOutlet GradientButton   *bogThenAndNowButton;
@property (retain, nonatomic) IBOutlet GradientButton *emailButton;
@property (retain, nonatomic) IBOutlet GradientButton *textButton;
@property (retain, nonatomic) IBOutlet GradientButton *tweetButton;
@property (retain, nonatomic) IBOutlet GradientButton *facebookButton;

@property (nonatomic, retain) IBOutlet UIButton *currentLocationButton;
@property (nonatomic, retain) IBOutlet UIButton *reframeButton;
@property (nonatomic, retain) IBOutlet UIButton *mapAppButton;

@property (nonatomic, retain) IBOutlet UIView *contentView;
@property (nonatomic, retain) IBOutlet UIView *mapView;
@property (nonatomic, retain) IBOutlet UIView *infoView;
@property (nonatomic, retain) IBOutlet UIView *bogView;
@property (retain, nonatomic) IBOutlet UIView *bogDeliveryMethodView;

@property (nonatomic, retain) IBOutlet UIWebView *infoWebView;
@property (nonatomic, retain) IBOutlet MKMapView *mapMapView;

@property (nonatomic, retain) IBOutlet UIView           *cameraOverlayView;
@property (nonatomic, retain) IBOutlet UIView           *photoOverlayView;
@property (nonatomic, retain) IBOutlet UIImageView      *photoForPhotoOverlayView;
@property (nonatomic, retain) IBOutlet UIView           *topScreenView;
@property (nonatomic, retain) IBOutlet UIView           *bottomScreenView;
@property (nonatomic, retain) IBOutlet UIView           *workingScreen;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *thenAndNowPushedActivityIndicator;

@property (nonatomic, retain) UIImagePickerController *imagePickerController;
@property (nonatomic, retain) PhotoLocation   *selectedPhoto;
@property (nonatomic, retain) UIImage *nowImage;

-(void) setPhotoLocationTo:(PhotoLocation *)photoLocation;
-(IBAction) bogPhotoOnlyButtonPressed:(id) sender;
-(IBAction) bogThenAndNowButtonPressed:(id) sender;
-(IBAction) doneButtonPressed:(id) sender;
-(IBAction) mapButtonPressed:(id) sender;
-(IBAction) infoButtonPressed:(id) sender;
-(IBAction) sendButtonPressed:(id) sender;
-(IBAction) photoButtonPressed:(id) sender;
-(IBAction) reframeButtonPressed;
-(IBAction) currentLocationButtonPressed;
-(IBAction) mapAppButtonPressed;
-(IBAction)emailButtonPressed:(id)sender;
-(IBAction)textButtonPressed:(id)sender;
-(IBAction)tweetButtonPressed:(id)sender;
-(IBAction)facebookButtonPressed:(id)sender;

-(void) reframeMap;
-(void) getBOGNowPhoto;
-(IBAction) snapPhoto:(id) sender;
-(IBAction) cancelPhoto:(id) sender;
-(IBAction) overlayToggle:(id) sender;
-(void) emailSinglePhotoImage ;
-(void) emailThenAndNowWithNowImage:(UIImage *) nowPhoto;
-(UIImage *) makeNowOnlyPostCard;
-(void) emailThenAndNowWithNowImage:(UIImage *) nowPhoto;
-(UIImage *) makeThenAndNowPostCardWith:(UIImage *)nowPhoto;
-(void) flipContentTo:(UIView *) toView flipForward:(BOOL)flipForward;

@end
























