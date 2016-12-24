//
//  CustomLocationView.m
//  Skope
//
//  Created by Nguyen Truong Luu on 5/2/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import "CustomLocationView.h"

@implementation CustomLocationView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self != nil)
    {
        
        
        self.backgroundColor = [UIColor clearColor];
        CGImageRef blueDot = [UIImage imageNamed:@"pointer_map.png"].CGImage;

        
        CGPoint blueDotCenter = CGPointMake((self.frame.size.width - (CGImageGetWidth(blueDot) / 2)) / 2, (self.frame.size.height - (CGImageGetHeight(blueDot) / 2)) / 2);
        
        CALayer *blueDotLayer = [CALayer layer];
        blueDotLayer.frame = CGRectMake(blueDotCenter.x, blueDotCenter.y , CGImageGetWidth(blueDot) / 2, CGImageGetHeight(blueDot) / 2);
        blueDotLayer.contents = (__bridge id)blueDot;
        blueDotLayer.shadowOpacity = 0.4;
        blueDotLayer.shadowColor = [UIColor blackColor].CGColor;
        blueDotLayer.shadowOffset = CGSizeMake(0.4, 0.3);
        blueDotLayer.shadowRadius = 1.0f;
        
        [self.layer insertSublayer:blueDotLayer above:self.layer];
        
    }
    
    return self;
}

- (void)setAnnotation:(id <MKAnnotation>)annotation
{
    [super setAnnotation:annotation];
    
    [self setNeedsDisplay];
}

@end
