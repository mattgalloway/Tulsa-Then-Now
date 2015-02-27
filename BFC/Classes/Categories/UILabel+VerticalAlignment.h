//
//  UILabel+VerticalAlignment.h
//  BFC
//
//  Created by Matt Galloway on 2/5/12.
//  Copyright (c) 2012 Architactile LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum
{
    VerticalAlignmentTop = 0, // default
    VerticalAlignmentMiddle,
    VerticalAlignmentBottom,
} VerticalAlignment;


@interface UILabel (VerticalAlignment)

- (void)setVerticalAlignmentWithMaxFrame:(CGRect)maxFrame withText:(NSString *)theText usingVerticalAlign:(VerticalAlignment)vertAlign; 

@end
