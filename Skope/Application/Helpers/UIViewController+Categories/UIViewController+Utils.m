//
//  UIViewController+Utils.m
//  Skope
//
//  Created by Nguyen Truong Luu on 5/5/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import "UIViewController+Utils.h"

@implementation UIViewController (Utils)
+ (BOOL)isVisible:(UIViewController*)viewcontroller {
    return [viewcontroller isViewLoaded] && viewcontroller.view.window;
}
@end
