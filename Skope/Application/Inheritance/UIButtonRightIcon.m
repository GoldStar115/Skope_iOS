//
//  UIButtonRightIcon.m
//  UnitsScanner
//
//  Created by Nguyen Truong Luu on 9/8/15.
//  Copyright (c) 2015 Phan Phuoc Luong. All rights reserved.
//

#import "UIButtonRightIcon.h"

@implementation UIButtonRightIcon

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize imageSize = self.imageView.frame.size;
    CGSize titleSize = self.titleLabel.frame.size;
    
    CGRect labelFrame = self.titleLabel.frame;
    labelFrame.origin.x = (self.frame.size.width - (imageSize.width + titleSize.width + 5))/2;//imageFrame.origin.x - labelFrame.size.width - 5.0f;
    self.titleLabel.frame = labelFrame;
    
    
    CGRect imageFrame = self.imageView.frame;
    imageFrame.origin.x = CGRectGetMaxX(labelFrame) + 5.0f;
    self.imageView.frame = imageFrame;
}


@end
