//
//  PostCardTemplate.m
//  BFC
//
//  Created by Matt Galloway on 3/4/12.
//  Copyright (c) 2012 Architactile LLC. All rights reserved.
//

#import "PostCardTemplate.h"

@implementation PostCardTemplate
@synthesize thenPhotoFrameView;
@synthesize thenPhotoView;
@synthesize nowPhotoFrameView;
@synthesize nowPhotoView;
@synthesize postCardView;
@synthesize titleTextView;
@synthesize descriptionTextView;

- (void)dealloc {
    [thenPhotoFrameView release];
    [thenPhotoView release];
    [nowPhotoFrameView release];
    [nowPhotoView release];
    [postCardView release];
    [titleTextView release];
    [descriptionTextView release];
    [super dealloc];
}

@end
