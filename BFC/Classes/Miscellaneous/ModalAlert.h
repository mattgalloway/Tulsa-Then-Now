/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

@interface ModalAlert : NSObject
+ (BOOL) ask: (NSString *) question;
+ (BOOL) confirm:(NSString *) statement;
+ (void) okWithTitle:(NSString *)title message:(NSString *)message;
+ (UIAlertView *) noButtonAlertWithTitle:(NSString *) title message:(NSString *) message;


@end
