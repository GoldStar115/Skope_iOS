//
//  UIBarButtonItem+Categories.m
//  Skope
//
//  Created by Nguyen Truong Luu on 9/13/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import "UIBarButtonItem+Categories.h"

@implementation UIBarButtonItem (Categories)

- (CGRect)frameInView:(UIView *)view {
    
    UIView *theView = self.customView;
    if (!theView.superview && [self respondsToSelector:@selector(view)]) {
        theView = [self performSelector:@selector(view)];
    }
    
    UIView *parentView = theView.superview;
    NSArray *subviews = parentView.subviews;
    
    NSUInteger indexOfView = [subviews indexOfObject:theView];
    NSUInteger subviewCount = subviews.count;
    
    if (subviewCount > 0 && indexOfView != NSNotFound) {
        UIView *button = [parentView.subviews objectAtIndex:indexOfView];
        return [button convertRect:button.bounds toView:view];
    } else {
        return CGRectZero;
    }
}
@end
