//
//  NTLRangeView.m
//  Skope
//
//  Created by Nguyen Truong Luu on 6/6/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import "NTLRangeView.h"

@interface NTLRangeView ()

@property (strong, nonatomic) NSArray *colors;

@property (strong, nonatomic) NSArray *parts;

@end

@implementation NTLRangeView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [UIColor clearColor];
}

- (id)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)fillColors:(NSArray*)colors forParts:(NSArray*)parts {
    
    self.colors = colors;
    self.parts = parts;
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    
    [super drawRect:rect];
    
    NSUInteger minPartToFill = MIN(_colors.count, _parts.count);
    
    CGFloat currentPercent = 0;
    CGFloat currentX = 0;
    
    for (NSUInteger i =0; i <minPartToFill; i++) {
        currentPercent += [_parts[i] floatValue];
        CGFloat currentPartWidth = currentPercent*self.bounds.size.width;
        CGRect currentRect = CGRectMake(currentX, 0, currentPartWidth, self.bounds.size.height);
        UIColor *currentColor = _colors[i];
        [currentColor setFill];
        UIRectFill(currentRect);
        currentX += currentPartWidth;
    }
    
}

@end
