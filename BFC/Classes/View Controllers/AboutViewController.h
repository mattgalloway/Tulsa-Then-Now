//
//  AboutViewController.h
//  BFC-iOS
//
//  Created by Matt Galloway on 10/7/11.
//  Copyright 2011 Architactile LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AboutViewController : UIViewController <UIWebViewDelegate> 

@property (retain, nonatomic) IBOutlet UIWebView *webView;

@end
