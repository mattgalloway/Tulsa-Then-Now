//
//  UINavigationItem+TypewritterTitle.m
//  BFC
//
//  Created by Matt Galloway on 2/26/12.
//  Copyright (c) 2012 Architactile LLC. All rights reserved.
//

#import "UINavigationItem+TypewritterTitle.h"

@implementation UINavigationItem (TypewritterTitle)

-(void) setTypewriterTitle{
    UILabel *customNavBarTitleView = [[UILabel alloc] initWithFrame: CGRectMake(0.0f, 0.0f, 250.0f, 40.0f)];
    customNavBarTitleView.text = self.title;
    customNavBarTitleView.font = [UIFont fontWithName:@"AmericanTypewriter-Bold" size:22.0f];
    customNavBarTitleView.textColor = [UIColor whiteColor];
    customNavBarTitleView.backgroundColor = [UIColor clearColor];
    customNavBarTitleView.textAlignment = UITextAlignmentCenter;
    
    self.titleView=customNavBarTitleView;
    
    [customNavBarTitleView release];
    
}

@end
