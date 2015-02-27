//
//  FacebookPostViewController.h
//  BFC
//
//  Created by Matt Galloway on 3/20/12.
//  Copyright (c) 2012 Architactile LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GradientButton;

@interface FacebookPostViewController : UIViewController
@property (retain, nonatomic) IBOutlet GradientButton *cancelButton;
@property (retain, nonatomic) IBOutlet GradientButton *postButton;
@property (retain, nonatomic) IBOutlet UITextView *postTextView;
@property (retain, nonatomic) IBOutlet UIImageView *postImageView;
@property (retain, nonatomic) UIImage *postCardImage;
@property (retain, nonatomic) NSString *postText;
@property (retain, nonatomic) IBOutlet UIView *waitView;

- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)postButtonPressed:(id)sender;

@end
