//
//  UILabel+VerticalAlignment.m
//  BFC
//
//  Created by Matt Galloway on 2/5/12.
//  Copyright (c) 2012 Architactile LLC. All rights reserved.
//

#import "UILabel+VerticalAlignment.h"

@implementation UILabel (VerticalAlignment)


- (void)setVerticalAlignmentWithMaxFrame:(CGRect)maxFrame withText:(NSString *)theText usingVerticalAlign:(VerticalAlignment)vertAlign {
    
    CGSize stringSize = [theText sizeWithFont:self.font constrainedToSize:maxFrame.size lineBreakMode:self.lineBreakMode];
    
    switch (vertAlign) {
        case VerticalAlignmentTop: // vertical align = top
            self.frame = CGRectMake(self.frame.origin.x, 
                                       self.frame.origin.y, 
                                       self.frame.size.width, 
                                       stringSize.height
                                       );
            break;
            
        case VerticalAlignmentMiddle: // vertical align = middle
            // don't do anything, lines will be placed in vertical middle by default
            break;
            
        case VerticalAlignmentBottom: // vertical align = bottom
            self.frame = CGRectMake(self.frame.origin.x, 
                                       (self.frame.origin.y + self.frame.size.height) - stringSize.height, 
                                       self.frame.size.width, 
                                       stringSize.height
                                       );
            break;
    }
    
    self.text = theText;
}


@end
