//
//  MyProfileInfoHeaderView.h
//  BLKFlexibleHeightBar Demo
//
//  Created by Bryan Keller on 2/19/15.
//  Copyright (c) 2015 Bryan Keller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BLKFlexibleHeightBar.h"

@class OtherUserProfileInfoHeaderView;

@protocol OtherUserProfileInfoHeaderViewDelegate <NSObject>

- (void)OtherUserProfileInfoHeaderViewDidClickShowAvatar:(UIButton*)sender;
- (void)OtherUserProfileInfoHeaderViewDidClickSendMSG:(UIButton*)sender;

@end

@interface OtherUserProfileInfoHeaderView : BLKFlexibleHeightBar

@property (nonatomic, weak) id<OtherUserProfileInfoHeaderViewDelegate> delegate;

@property (strong, nonatomic) UIImageView    *imgView_UserAvatar;
@property (strong, nonatomic) UILabel        *lbl_UserName;
@property (strong, nonatomic) UIButton       *btn_SendMessage;
@property (strong, nonatomic) UIButton       *btn_ShowFullAvatar;

@end
