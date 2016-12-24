//
//  MyProfileInfoHeaderView.h
//  BLKFlexibleHeightBar Demo
//
//  Created by Bryan Keller on 2/19/15.
//  Copyright (c) 2015 Bryan Keller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BLKFlexibleHeightBar.h"

@class MyProfileInfoHeaderView;

@protocol MyProfileInfoHeaderViewDelegate <NSObject>

- (void)MyProfileInfoHeaderViewDidClickShowAvatar:(UIButton*)sender;
- (void)MyProfileInfoHeaderViewDidSelectMyPost:(UIButton*)sender;
- (void)MyProfileInfoHeaderViewDidSelectActivity:(UIButton*)sender;

@end

@interface MyProfileInfoHeaderView : BLKFlexibleHeightBar

@property (nonatomic, weak) id<MyProfileInfoHeaderViewDelegate> delegate;

@property (strong, nonatomic) UIImageView    *imgView_UserAvatar;
@property (strong, nonatomic) UITextField    *tf_UserName;
@property (strong, nonatomic) UIButton       *btn_ChangeUserAvatar;
@property (strong, nonatomic) UIButton       *btn_EditUserName;
@property (strong, nonatomic) UIButton       *btn_MyPosts;
@property (strong, nonatomic) UIButton       *btn_Activity;
@property (strong, nonatomic) UIButton       *btn_ShowFullAvatar;
@property (strong, nonatomic) JSBadgeView       *activity_badgeView;

@property (weak, nonatomic) UIView* touchBeganView;
@end
