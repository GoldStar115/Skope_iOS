//
//  UIViewController+IsVisible.m
//  Skope
//
//  Created by Nguyen Truong Luu on 8/10/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import "UIViewController+IsVisible.h"

@implementation UIViewController (IsVisible)

- (BOOL)isVisible {
    return [self isViewLoaded] && self.view.window;
}

@end
