//
//  CSAlwaysOnTopHeader.h
//  CSStickyHeaderFlowLayoutDemo
//
//  Created by James Tang on 6/4/14.
//  Copyright (c) 2014 Jamz Tang. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kButtonShadowRadius     3.0
#define MaxBarHeigt             70.0
#define MinBarHeigt             0.0
#define ButtonBottomPadding     15.0
#define ButtonSize              CGSizeMake(100.0,32.0)

@class NewPostNofiticationTopHeaderView;
@protocol NewPostNofiticationTopHeaderViewDelegate <NSObject>

- (void)TopHeaderViewButtonClicked:(UIButton *)sender;

@end

@interface NewPostNofiticationTopHeaderView : BLKFlexibleHeightBar
@property (nonatomic, weak) id<NewPostNofiticationTopHeaderViewDelegate> delegate;
@property (strong, nonatomic) UIButton *btn_newPost;

@end
