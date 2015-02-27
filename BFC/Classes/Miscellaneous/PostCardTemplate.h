//
//  PostCardTemplate.h
//  BFC
//
//  Created by Matt Galloway on 3/4/12.
//  Copyright (c) 2012 Architactile LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PostCardTemplate : NSObject
@property (retain, nonatomic) IBOutlet UIView *thenPhotoFrameView;
@property (retain, nonatomic) IBOutlet UIImageView *thenPhotoView;
@property (retain, nonatomic) IBOutlet UIView *nowPhotoFrameView;
@property (retain, nonatomic) IBOutlet UIImageView *nowPhotoView;
@property (retain, nonatomic) IBOutlet UIView *postCardView;
@property (retain, nonatomic) IBOutlet UITextView *titleTextView;
@property (retain, nonatomic) IBOutlet UITextView *descriptionTextView;

@end
