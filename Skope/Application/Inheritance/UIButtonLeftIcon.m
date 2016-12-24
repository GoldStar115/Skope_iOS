//
//  UIButtonLeftIcon.m
//  UnitsScanner
//
//  Created by Nguyen Truong Luu on 9/8/15.
//  Copyright (c) 2015 Phan Phuoc Luong. All rights reserved.
//

#import "UIButtonLeftIcon.h"

@implementation UIButtonLeftIcon

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
    
    CGRect imageFrame = self.imageView.frame;
    imageFrame.origin.x = (self.frame.size.width - (imageSize.width + titleSize.width + 5))/2;
    self.imageView.frame = imageFrame;
    
    CGRect labelFrame = self.titleLabel.frame;
    labelFrame.origin.x = CGRectGetMaxX(imageFrame) + 5.0f;
    self.titleLabel.frame = labelFrame;
}

@end
