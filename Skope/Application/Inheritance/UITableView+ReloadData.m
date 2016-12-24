//
//  UITableView+ReloadData.m
//  Skope
//
//  Created by Nguyen Truong Luu on 1/15/15.
//  Copyright (c) 2015 Nguyen Truong Luu. All rights reserved.
//

#import "UITableView+ReloadData.h"

@implementation UITableView (ReloadData)
- (void)reloadData:(BOOL)animated completion:(void (^)(BOOL finished))completion
{
    [self reloadData];
    
    if (animated) {
        
        [UIView animateWithDuration:0.4 animations:^{
            CATransition *animation = [CATransition animation];
            [animation setType:kCATransitionPush];
            [animation setSubtype:kCATransitionFromBottom];
            [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
            [animation setFillMode:kCAFillModeBoth];
            //[animation setDuration:.3];
            [[self layer] addAnimation:animation forKey:@"UITableViewReloadDataAnimationKey"];
        } completion:^(BOOL finished) {
            if (completion) {
                completion(finished);
            }
        }];
    } else {
        if (completion) {
            completion(YES);
        }
    }
}
@end
