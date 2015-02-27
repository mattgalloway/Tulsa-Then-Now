//
//  DataLoader.h
//  BFC
//
//  Created by Matt Galloway on 1/23/12.
//  Copyright (c) 2012 Architactile LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataLoader : NSObject

+(void) loadCSVFile:(NSString *) csvPath;

@end
