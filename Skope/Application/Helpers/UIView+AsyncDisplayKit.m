//
//  UIView+AsyncDisplayKit.m
//  xml parser demo
//
//  Created by Nguyen Truong Luu on 5/17/15.
//  Copyright (c) 2015 Nguyen Truong Luu. All rights reserved.
//

#import "UIView+AsyncDisplayKit.h"

@implementation UIView (AsyncDisplayKit)

- (void)addSubnode:(ASDisplayNode *)node
{
    if (node.layerBacked) {
        [self.layer addSublayer:node.layer];
    } else {
        [self addSubview:node.view];
    }
}

@end
