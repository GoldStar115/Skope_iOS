//
//  CSAlwaysOnTopHeader.m
//  CSStickyHeaderFlowLayoutDemo
//
//  Created by James Tang on 6/4/14.
//  Copyright (c) 2014 Jamz Tang. All rights reserved.
//

#import "NewPostNofiticationTopHeaderView.h"
#import "UIImage+RoundedCorner.h"

@interface NewPostNofiticationTopHeaderView () <UISearchBarDelegate>

@end

@implementation NewPostNofiticationTopHeaderView


- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        [self configureBar];
    }
    
    return self;
}

- (void)configureBar {
    
    [super  setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    
    [self setClipsToBounds:YES];
    [self setBackgroundColor:[UIColor clearColor]];
    
    UIButton *btn_newPost = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, ButtonSize.width, ButtonSize.height)];
    [btn_newPost setTitle:@"New post" forState:UIControlStateNormal];
    [btn_newPost setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn_newPost.titleLabel setFont:[UIFont systemFontOfSize:16.0f]];
    [btn_newPost setBackgroundColor:[UIColor colorWithRed:69.0/255 green:185.0/255 blue:228.0/255 alpha:1.0]];
    [btn_newPost.layer setCornerRadius:17.0f];
    
    CALayer *shadowlayer = [CALayer layer];
    shadowlayer.backgroundColor = btn_newPost.backgroundColor.CGColor;
    shadowlayer.shadowOffset = CGSizeMake(0, 0);
    shadowlayer.shadowRadius = kButtonShadowRadius;
    shadowlayer.shadowColor = [UIColor blackColor].CGColor;
    shadowlayer.shadowOpacity = 0.8;
    shadowlayer.frame = btn_newPost.bounds;
    shadowlayer.cornerRadius = 17.0;
    [btn_newPost.layer insertSublayer:shadowlayer atIndex:0];
    
    BLKFlexibleHeightBarSubviewLayoutAttributes *initialSearchFieldLayoutAttributes = [[BLKFlexibleHeightBarSubviewLayoutAttributes alloc] init];
    initialSearchFieldLayoutAttributes.frame = CGRectMake([UIScreen mainScreen].bounds.size.width/2 - ButtonSize.width/2 , self.maximumBarHeight - ButtonSize.height - ButtonBottomPadding, ButtonSize.width , ButtonSize.height);
    initialSearchFieldLayoutAttributes.zIndex = 1024;
    
    [btn_newPost addLayoutAttributes:initialSearchFieldLayoutAttributes forProgress:0.0];
    [btn_newPost addLayoutAttributes:initialSearchFieldLayoutAttributes forProgress:ButtonBottomPadding/(MaxBarHeigt-MinBarHeigt)];
    
    BLKFlexibleHeightBarSubviewLayoutAttributes *finalSearchFieldLayoutAttributes = [[BLKFlexibleHeightBarSubviewLayoutAttributes alloc] initWithExistingLayoutAttributes:initialSearchFieldLayoutAttributes];
    finalSearchFieldLayoutAttributes.transform = CGAffineTransformMakeTranslation(0.0, - 1.0 * (MaxBarHeigt - MinBarHeigt - ButtonBottomPadding));
    finalSearchFieldLayoutAttributes.alpha = 0.0;
    
    
    [btn_newPost addLayoutAttributes:finalSearchFieldLayoutAttributes forProgress:0.8];
    [btn_newPost addLayoutAttributes:finalSearchFieldLayoutAttributes forProgress:1.0];
    
    self.btn_newPost = btn_newPost;
    
    [self addSubview:btn_newPost];
    
    [self.btn_newPost addTarget:self action:@selector(action_reloadForNewPost:) forControlEvents:UIControlEventTouchUpInside];
    
    
    //===Update status for self
    
    [UserDefault currentUser].haveNewPostNotification = @"0";
    BOOL haveNotification = [[UserDefault currentUser].haveNewPostNotification boolValue];
    [self setUserInteractionEnabled:haveNotification];
    [self.btn_newPost setUserInteractionEnabled:haveNotification];
    [self setAlpha:haveNotification?1.0:0.0];
    [self.btn_newPost setAlpha:haveNotification?1.0:0.0];
    [self setHidden:!haveNotification];
    [self.btn_newPost setHidden:!haveNotification];

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(haveNewPost) name:NEW_POST_NOTIFICATION object:nil];
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    //_btn_newPost.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMaxY(self.bounds) - CGRectGetHeight(_btn_newPost.bounds)/2 - 1.9*kButtonShadowRadius);
}

- (void)haveNewPost {

    BOOL haveNotification = [[UserDefault currentUser].haveNewPostNotification boolValue];
    [self setUserInteractionEnabled:haveNotification];
    [self.btn_newPost setUserInteractionEnabled:haveNotification];
    
    [UIView animateWithDuration:0.4 animations:^{
        [self setAlpha:haveNotification?1.0:0.0];
        [self.btn_newPost setAlpha:haveNotification?1.0:0.0];
    } completion:^(BOOL finished) {
        [self setHidden:!haveNotification];
        [self.btn_newPost setHidden:!haveNotification];
    }];

}


- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    CGPoint pointInButton = [self convertPoint:point toView:self.btn_newPost];
    
    if ([self.btn_newPost pointInside:pointInButton withEvent:event])
        return self.btn_newPost;
    
    if ([self.btn_newPost pointInside:point withEvent:event] && !self.hidden)
        return self.btn_newPost;
    
    return nil;
}

#pragma mark - Button Clicked

- (IBAction)action_reloadForNewPost:(id)sender
{
    
    //===Update status for self

    BOOL haveNotification = NO;//[[UserDefault currentUser].haveNewPostNotification boolValue];
    [self setUserInteractionEnabled:haveNotification];
    [self.btn_newPost setUserInteractionEnabled:haveNotification];
    
    [UIView animateWithDuration:0.4 animations:^{
        [self setAlpha:haveNotification?1.0:0.0];
        [self.btn_newPost setAlpha:haveNotification?1.0:0.0];
    } completion:^(BOOL finished) {
        [self setHidden:!haveNotification];
        [self.btn_newPost setHidden:!haveNotification];
    }];
    
    UIButton *button = (UIButton*)sender;
    if ([_delegate respondsToSelector:@selector(TopHeaderViewButtonClicked:)]) {
        [_delegate TopHeaderViewButtonClicked:button];
    }
}

@end
