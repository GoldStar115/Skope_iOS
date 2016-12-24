//
//  MyProfileInfoHeaderView.m
//  BLKFlexibleHeightBar Demo
//
//  Created by Bryan Keller on 2/19/15.
//  Copyright (c) 2015 Bryan Keller. All rights reserved.
//

#import "MyProfileInfoHeaderView.h"
#import "UIButtonLeftIcon.h"

#define kActiveButtonColor          [UIColor colorWithRed:21.0/255 green:143.0/255 blue:191.0/255 alpha:1.0]
#define kInActiveButtonColor        [UIColor colorWithRed:170.0/255 green:170.0/255 blue:170.0/255 alpha:1.0]

#define kActiveButtonFont           [UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0f]
#define kInActiveButtonFont         [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0f]

#define kChangePictureButtonFont    [UIFont fontWithName:@"HelveticaNeue" size:13.0f]
#define kEditNameButtonFont         [UIFont systemFontOfSize:11.0f]

#define kUserNameTextFieldFont      [UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0f]

@implementation MyProfileInfoHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        [self configureBar];
    }
    
    return self;
}

- (void)configureBar
{
    // Configure bar appearence
    self.maximumBarHeight = 330.0;
    self.minimumBarHeight = 50.0;   
    
     // Add and configure name label
//     UILabel *nameLabel = [[UILabel alloc] init];
//     nameLabel.font = [UIFont systemFontOfSize:22.0];
//     nameLabel.textColor = [UIColor whiteColor];
//     nameLabel.text = @"Bryan Keller";
//    
//     BLKFlexibleHeightBarSubviewLayoutAttributes *initialNameLabelLayoutAttributes = [[BLKFlexibleHeightBarSubviewLayoutAttributes alloc] init];
//    initialNameLabelLayoutAttributes.size = [nameLabel sizeThatFits:CGSizeZero];
//    initialNameLabelLayoutAttributes.center = CGPointMake(self.frame.size.width*0.5, self.maximumBarHeight-50.0);
//
//    
//    BLKFlexibleHeightBarSubviewLayoutAttributes *midwayNameLabelLayoutAttributes = [[BLKFlexibleHeightBarSubviewLayoutAttributes alloc] initWithExistingLayoutAttributes:initialNameLabelLayoutAttributes];
//    midwayNameLabelLayoutAttributes.center = CGPointMake(self.frame.size.width*0.5, (self.maximumBarHeight-self.minimumBarHeight)*0.4+self.minimumBarHeight-50.0);
//
//    
//    BLKFlexibleHeightBarSubviewLayoutAttributes *finalNameLabelLayoutAttributes = [[BLKFlexibleHeightBarSubviewLayoutAttributes alloc] initWithExistingLayoutAttributes:midwayNameLabelLayoutAttributes];
//    finalNameLabelLayoutAttributes.center = CGPointMake(self.frame.size.width*0.5, self.minimumBarHeight-25.0);
//
//    
//    [nameLabel addLayoutAttributes:initialNameLabelLayoutAttributes forProgress:0.0];
//    [nameLabel addLayoutAttributes:midwayNameLabelLayoutAttributes forProgress:0.6];
//    [nameLabel addLayoutAttributes:finalNameLabelLayoutAttributes forProgress:1.0];
//    
//    
//    [self addSubview:nameLabel];
    
    // Add and configure profile image
    UIImageView *profileImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ProfilePicture.png"]];
    profileImageView.contentMode = UIViewContentModeScaleAspectFill;
    profileImageView.clipsToBounds = YES;
    profileImageView.layer.cornerRadius = 75.0;
    profileImageView.layer.borderWidth = 3.0;
    profileImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    
    BLKFlexibleHeightBarSubviewLayoutAttributes *initialProfileImageViewLayoutAttributes = [[BLKFlexibleHeightBarSubviewLayoutAttributes alloc] init];
    initialProfileImageViewLayoutAttributes.size = CGSizeMake(150.0, 150.0);
    initialProfileImageViewLayoutAttributes.center = CGPointMake(self.frame.size.width*0.5, self.maximumBarHeight-(240.0 + CGRectGetHeight(profileImageView.bounds)/2));//CGPointMake(self.frame.size.width*0.5, 110.0);
    
    
    BLKFlexibleHeightBarSubviewLayoutAttributes *midwayProfileImageViewLayoutAttributes = [[BLKFlexibleHeightBarSubviewLayoutAttributes alloc] initWithExistingLayoutAttributes:initialProfileImageViewLayoutAttributes];
    midwayProfileImageViewLayoutAttributes.center = CGPointMake(self.frame.size.width*0.5, (self.maximumBarHeight-self.minimumBarHeight)*0.4+self.minimumBarHeight-(240.0 + CGRectGetHeight(profileImageView.bounds)/2));//CGPointMake(self.frame.size.width*0.5, 110.0);
    midwayProfileImageViewLayoutAttributes.transform = CGAffineTransformMakeScale(0.6, 0.6);
    midwayProfileImageViewLayoutAttributes.alpha = 0.5;
    
    
    BLKFlexibleHeightBarSubviewLayoutAttributes *finalProfileImageViewLayoutAttributes = [[BLKFlexibleHeightBarSubviewLayoutAttributes alloc] initWithExistingLayoutAttributes:midwayProfileImageViewLayoutAttributes];
    finalProfileImageViewLayoutAttributes.center = CGPointMake(self.frame.size.width*0.5, self.minimumBarHeight-(240.0 + CGRectGetHeight(profileImageView.bounds)/2));//CGPointMake(self.frame.size.width*0.5, 110.0);
    finalProfileImageViewLayoutAttributes.transform = CGAffineTransformMakeScale(0.3, 0.3);
    finalProfileImageViewLayoutAttributes.alpha = 0.0;
    
    [profileImageView addLayoutAttributes:initialProfileImageViewLayoutAttributes forProgress:0.0]; //0.0
    [profileImageView addLayoutAttributes:midwayProfileImageViewLayoutAttributes forProgress:0.6];  //0.2
    [profileImageView addLayoutAttributes:finalProfileImageViewLayoutAttributes forProgress:1.0];   //0.5
    
    self.imgView_UserAvatar = profileImageView;
    
    [self addSubview:profileImageView];
    
    
    //  Button show user avatar
    
    UIButton *btn_ShowFullAvatar = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 150.0, 150.0)];
    [btn_ShowFullAvatar setBackgroundColor:[UIColor clearColor]];
    [btn_ShowFullAvatar setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    [btn_ShowFullAvatar setTitle:@"" forState:UIControlStateNormal];
    
    [btn_ShowFullAvatar addLayoutAttributes:initialProfileImageViewLayoutAttributes forProgress:0.0]; //0.0
    [btn_ShowFullAvatar addLayoutAttributes:midwayProfileImageViewLayoutAttributes forProgress:0.6];  //0.2
    [btn_ShowFullAvatar addLayoutAttributes:finalProfileImageViewLayoutAttributes forProgress:1.0];   //0.5
    
    [btn_ShowFullAvatar addTarget:self action:@selector(action_ShowFullAvatar:) forControlEvents:UIControlEventTouchUpInside];
    
    self.btn_ShowFullAvatar = btn_ShowFullAvatar;
    
    [self addSubview:btn_ShowFullAvatar];
    
    
    // Add and configure change picture Button
    
    UIButton *changeAvatarBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 120.0, 34.0)];
    changeAvatarBtn.titleLabel.font = kChangePictureButtonFont;
    [changeAvatarBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [changeAvatarBtn setTitle:@"Change Picture" forState:UIControlStateNormal];
    
    BLKFlexibleHeightBarSubviewLayoutAttributes *initialchangeAvatarBtnLayoutAttributes = [[BLKFlexibleHeightBarSubviewLayoutAttributes alloc] init];
    initialchangeAvatarBtnLayoutAttributes.size = CGSizeMake(120.0, 34.0);//[changeAvatarBtn sizeThatFits:CGSizeZero];
    initialchangeAvatarBtnLayoutAttributes.center = CGPointMake(self.frame.size.width*0.5, self.maximumBarHeight-(125.0 + CGRectGetHeight(changeAvatarBtn.bounds)/2));
    
    BLKFlexibleHeightBarSubviewLayoutAttributes *midwaychangeAvatarBtnLayoutAttributes = [[BLKFlexibleHeightBarSubviewLayoutAttributes alloc] initWithExistingLayoutAttributes:initialchangeAvatarBtnLayoutAttributes];
    midwaychangeAvatarBtnLayoutAttributes.center = CGPointMake(self.frame.size.width*0.5, (self.maximumBarHeight-self.minimumBarHeight)*0.4+self.minimumBarHeight-(125.0 + CGRectGetHeight(changeAvatarBtn.bounds)/2));
    midwaychangeAvatarBtnLayoutAttributes.alpha = 0.5;
    
    
    BLKFlexibleHeightBarSubviewLayoutAttributes *finalchangeAvatarBtnLayoutAttributes = [[BLKFlexibleHeightBarSubviewLayoutAttributes alloc] initWithExistingLayoutAttributes:midwaychangeAvatarBtnLayoutAttributes];
    finalchangeAvatarBtnLayoutAttributes.center = CGPointMake(self.frame.size.width*0.5, self.minimumBarHeight-(125.0 + CGRectGetHeight(changeAvatarBtn.bounds)/2));
    finalchangeAvatarBtnLayoutAttributes.alpha = 0.0;
    
    [changeAvatarBtn addLayoutAttributes:initialchangeAvatarBtnLayoutAttributes forProgress:0.0];
    [changeAvatarBtn addLayoutAttributes:midwaychangeAvatarBtnLayoutAttributes forProgress:0.6];
    [changeAvatarBtn addLayoutAttributes:finalchangeAvatarBtnLayoutAttributes forProgress:1.0];
    
    self.btn_ChangeUserAvatar = changeAvatarBtn;
    
    [self addSubview:changeAvatarBtn];
    
    
    // Add UserName textField
    
    UITextField *userNameTfl = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 280.0, 40.0)];
    userNameTfl.font = kUserNameTextFieldFont;
    userNameTfl.textColor = [UIColor blackColor];
    userNameTfl.textAlignment = NSTextAlignmentCenter;
    userNameTfl.returnKeyType = UIReturnKeyDone;
    userNameTfl.text = @"";
    
    BLKFlexibleHeightBarSubviewLayoutAttributes *initialuserNameTflLayoutAttributes = [[BLKFlexibleHeightBarSubviewLayoutAttributes alloc] init];
    initialuserNameTflLayoutAttributes.size = CGSizeMake(280.0, 40.0); //[userNameTfl sizeThatFits:CGSizeZero];
    initialuserNameTflLayoutAttributes.center = CGPointMake(self.frame.size.width*0.5, self.maximumBarHeight-(85.0 + CGRectGetHeight(userNameTfl.bounds)/2));
    
    
    BLKFlexibleHeightBarSubviewLayoutAttributes *midwayuserNameTflLayoutAttributes = [[BLKFlexibleHeightBarSubviewLayoutAttributes alloc] initWithExistingLayoutAttributes:initialuserNameTflLayoutAttributes];
    midwayuserNameTflLayoutAttributes.center = CGPointMake(self.frame.size.width*0.5, (self.maximumBarHeight-self.minimumBarHeight)*0.4+self.minimumBarHeight-(85.0 + CGRectGetHeight(userNameTfl.bounds)/2));
    midwayuserNameTflLayoutAttributes.alpha = 0.5;
    
    
    BLKFlexibleHeightBarSubviewLayoutAttributes *finaluserNameTflLayoutAttributes = [[BLKFlexibleHeightBarSubviewLayoutAttributes alloc] initWithExistingLayoutAttributes:midwayuserNameTflLayoutAttributes];
    finaluserNameTflLayoutAttributes.center = CGPointMake(self.frame.size.width*0.5, self.minimumBarHeight-(85.0 + CGRectGetHeight(userNameTfl.bounds)/2));
    finaluserNameTflLayoutAttributes.alpha = 0.0;
    
    [userNameTfl addLayoutAttributes:initialuserNameTflLayoutAttributes forProgress:0.0];
    [userNameTfl addLayoutAttributes:midwayuserNameTflLayoutAttributes forProgress:0.6];
    [userNameTfl addLayoutAttributes:finaluserNameTflLayoutAttributes forProgress:1.0];
    
    self.tf_UserName = userNameTfl;
    
    [self addSubview:userNameTfl];
    
    
    // Add and configure Change Name Button
    
    
    UIButtonLeftIcon *changeNameBtn = [[UIButtonLeftIcon alloc] initWithFrame:CGRectMake(0, 0, 140.0, 34.0)];
    changeNameBtn.titleLabel.font = kEditNameButtonFont;
    [changeNameBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [changeNameBtn setTitle:@"Edit Name" forState:UIControlStateNormal];
    [changeNameBtn setImage:[UIImage imageNamed:@"ic_change_name"] forState:UIControlStateNormal];
    
    BLKFlexibleHeightBarSubviewLayoutAttributes *initialchangeNameBtnLayoutAttributes = [[BLKFlexibleHeightBarSubviewLayoutAttributes alloc] init];
    initialchangeNameBtnLayoutAttributes.size = CGSizeMake(120.0, 34.0);//[changeNameBtn sizeThatFits:CGSizeZero];
    initialchangeNameBtnLayoutAttributes.center = CGPointMake(self.frame.size.width*0.5, self.maximumBarHeight-(50.0 + CGRectGetHeight(changeNameBtn.bounds)/2));
    
    
    BLKFlexibleHeightBarSubviewLayoutAttributes *midwaychangeNameBtnLayoutAttributes = [[BLKFlexibleHeightBarSubviewLayoutAttributes alloc] initWithExistingLayoutAttributes:initialchangeNameBtnLayoutAttributes];
    midwaychangeNameBtnLayoutAttributes.center = CGPointMake(self.frame.size.width*0.5, (self.maximumBarHeight-self.minimumBarHeight)*0.4+self.minimumBarHeight-(50.0 + CGRectGetHeight(changeNameBtn.bounds)/2));
    midwaychangeNameBtnLayoutAttributes.alpha = 0.5;
    
    
    BLKFlexibleHeightBarSubviewLayoutAttributes *finalchangeNameBtnLayoutAttributes = [[BLKFlexibleHeightBarSubviewLayoutAttributes alloc] initWithExistingLayoutAttributes:midwaychangeNameBtnLayoutAttributes];
    finalchangeNameBtnLayoutAttributes.center = CGPointMake(self.frame.size.width*0.5, self.minimumBarHeight-(50.0 + CGRectGetHeight(changeNameBtn.bounds)/2));
    finalchangeNameBtnLayoutAttributes.alpha = 0.0;
    
    [changeNameBtn addLayoutAttributes:initialchangeNameBtnLayoutAttributes forProgress:0.0];
    [changeNameBtn addLayoutAttributes:midwaychangeNameBtnLayoutAttributes forProgress:0.6];
    [changeNameBtn addLayoutAttributes:finalchangeNameBtnLayoutAttributes forProgress:1.0];
    
    self.btn_EditUserName = changeNameBtn;
    
    [self addSubview:changeNameBtn];
    
    
    // Add and configure SwitchTab Button
    
    UIButton *MyPostBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100.0, 34.0)];
    MyPostBtn.titleLabel.font = kActiveButtonFont;
    [MyPostBtn setTitleColor:kActiveButtonColor forState:UIControlStateNormal];
    [MyPostBtn setTitle:@"My Posts" forState:UIControlStateNormal];
    
    BLKFlexibleHeightBarSubviewLayoutAttributes *initialMyPostBtnLayoutAttributes = [[BLKFlexibleHeightBarSubviewLayoutAttributes alloc] init];
    initialMyPostBtnLayoutAttributes.size = CGSizeMake(100.0, 34.0);//[MyPostBtn sizeThatFits:CGSizeZero];
    initialMyPostBtnLayoutAttributes.center = CGPointMake(self.frame.size.width*0.3, self.maximumBarHeight-30.0);
    
    
    BLKFlexibleHeightBarSubviewLayoutAttributes *midwayMyPostBtnLayoutAttributes = [[BLKFlexibleHeightBarSubviewLayoutAttributes alloc] initWithExistingLayoutAttributes:initialMyPostBtnLayoutAttributes];
    midwayMyPostBtnLayoutAttributes.center = CGPointMake(self.frame.size.width*0.3, (self.maximumBarHeight-self.minimumBarHeight)*0.4+self.minimumBarHeight-30.0);
    
    
    BLKFlexibleHeightBarSubviewLayoutAttributes *finalMyPostBtnLayoutAttributes = [[BLKFlexibleHeightBarSubviewLayoutAttributes alloc] initWithExistingLayoutAttributes:midwayMyPostBtnLayoutAttributes];
    finalMyPostBtnLayoutAttributes.center = CGPointMake(self.frame.size.width*0.3, self.minimumBarHeight-30.0);
    
    
    [MyPostBtn addLayoutAttributes:initialMyPostBtnLayoutAttributes forProgress:0.0];
    [MyPostBtn addLayoutAttributes:midwayMyPostBtnLayoutAttributes forProgress:0.6];
    [MyPostBtn addLayoutAttributes:finalMyPostBtnLayoutAttributes forProgress:1.0];
    
    [MyPostBtn addTarget:self action:@selector(action_MyPost:) forControlEvents:UIControlEventTouchUpInside];
    MyPostBtn.showsTouchWhenHighlighted = YES;
    
    self.btn_MyPosts = MyPostBtn;
    
    [self addSubview:MyPostBtn];
    
    
    // Add and configure name label
    
    UIButton *ActivityBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100.0, 34.0)];
    ActivityBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [ActivityBtn setTitleColor:kInActiveButtonColor forState:UIControlStateNormal];
    [ActivityBtn setTitle:@"Activity" forState:UIControlStateNormal];
    
    BLKFlexibleHeightBarSubviewLayoutAttributes *initialActivityBtnLayoutAttributes = [[BLKFlexibleHeightBarSubviewLayoutAttributes alloc] init];
    initialActivityBtnLayoutAttributes.size = CGSizeMake(100.0, 34.0);//[ActivityBtn sizeThatFits:CGSizeZero];
    initialActivityBtnLayoutAttributes.center = CGPointMake(self.frame.size.width*0.7, self.maximumBarHeight-30.0);
    
    
    BLKFlexibleHeightBarSubviewLayoutAttributes *midwayActivityBtnLayoutAttributes = [[BLKFlexibleHeightBarSubviewLayoutAttributes alloc] initWithExistingLayoutAttributes:initialActivityBtnLayoutAttributes];
    midwayActivityBtnLayoutAttributes.center = CGPointMake(self.frame.size.width*0.7, (self.maximumBarHeight-self.minimumBarHeight)*0.4+self.minimumBarHeight-30.0);
    
    
    BLKFlexibleHeightBarSubviewLayoutAttributes *finalActivityBtnLayoutAttributes = [[BLKFlexibleHeightBarSubviewLayoutAttributes alloc] initWithExistingLayoutAttributes:midwayActivityBtnLayoutAttributes];
    finalActivityBtnLayoutAttributes.center = CGPointMake(self.frame.size.width*0.7, self.minimumBarHeight-30.0);
    
    
    [ActivityBtn addLayoutAttributes:initialActivityBtnLayoutAttributes forProgress:0.0];
    [ActivityBtn addLayoutAttributes:midwayActivityBtnLayoutAttributes forProgress:0.6];
    [ActivityBtn addLayoutAttributes:finalActivityBtnLayoutAttributes forProgress:1.0];
    
    [ActivityBtn addTarget:self action:@selector(action_Activity:) forControlEvents:UIControlEventTouchUpInside];
    ActivityBtn.showsTouchWhenHighlighted = YES;
    ActivityBtn.clipsToBounds = NO;
    ActivityBtn.layer.masksToBounds = NO;
    
    self.btn_Activity = ActivityBtn;
    
    [self addSubview:ActivityBtn];
    
    
    
    //  Add Badget View
    
    self.activity_badgeView = [[JSBadgeView alloc] initWithParentView:self.btn_Activity alignment:JSBadgeViewAlignmentTopRight];
    _activity_badgeView.badgeTextFont = FONT_NOTIFICATION_BAGED;
    _activity_badgeView.leftMargin = 10.0;
    _activity_badgeView.badgeText = [UserDefault currentUser].commentBagedNumber;
    [_activity_badgeView setHidden:[[UserDefault currentUser].commentBagedNumber integerValue] == 0];
    
    
    // Add and configure name label
    
    UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width-40, 12)];
    lineLabel.font = [UIFont systemFontOfSize:17.0];
    lineLabel.textColor = APP_COMMON_GREEN_COLOR;
    lineLabel.textAlignment = NSTextAlignmentCenter;
    lineLabel.text = @".....................................................................................";
    
    BLKFlexibleHeightBarSubviewLayoutAttributes *initiallineLabelLayoutAttributes = [[BLKFlexibleHeightBarSubviewLayoutAttributes alloc] init];
    initiallineLabelLayoutAttributes.size = CGSizeMake([UIScreen mainScreen].bounds.size.width-40, 12);//[lineLabel sizeThatFits:CGSizeZero];
    initiallineLabelLayoutAttributes.center = CGPointMake(self.frame.size.width*0.5, self.maximumBarHeight-15.0);
    
    
    BLKFlexibleHeightBarSubviewLayoutAttributes *midwaylineLabelLayoutAttributes = [[BLKFlexibleHeightBarSubviewLayoutAttributes alloc] initWithExistingLayoutAttributes:initiallineLabelLayoutAttributes];
    midwaylineLabelLayoutAttributes.center = CGPointMake(self.frame.size.width*0.5, (self.maximumBarHeight-self.minimumBarHeight)*0.4+self.minimumBarHeight-15.0);
    
    
    BLKFlexibleHeightBarSubviewLayoutAttributes *finallineLabelLayoutAttributes = [[BLKFlexibleHeightBarSubviewLayoutAttributes alloc] initWithExistingLayoutAttributes:midwaylineLabelLayoutAttributes];
    finallineLabelLayoutAttributes.center = CGPointMake(self.frame.size.width*0.5, self.minimumBarHeight-15.0);
    
    
    [lineLabel addLayoutAttributes:initiallineLabelLayoutAttributes forProgress:0.0];
    [lineLabel addLayoutAttributes:midwaylineLabelLayoutAttributes forProgress:0.6];
    [lineLabel addLayoutAttributes:finallineLabelLayoutAttributes forProgress:1.0];
    
    [self addSubview:lineLabel];
    

}


- (IBAction)action_MyPost:(id)sender
{
    NSLog(@"My Post clicked");
    
    if ([_delegate respondsToSelector:@selector(MyProfileInfoHeaderViewDidSelectMyPost:)]) {
        [_delegate MyProfileInfoHeaderViewDidSelectMyPost:sender];
        
        [Common addPopAnimationToLayer:self.btn_MyPosts.layer withBounce:0.2 damp:0.080];
        
        [UIView animateWithDuration:0.7 animations:^{
            
            [self.btn_Activity setTitleColor:kInActiveButtonColor forState:UIControlStateNormal];
            self.btn_Activity.titleLabel.font = kInActiveButtonFont;
            
            [self.btn_MyPosts setTitleColor:kActiveButtonColor forState:UIControlStateNormal];
            self.btn_MyPosts.titleLabel.font = kActiveButtonFont;
            
        }];
    }
    
}

- (IBAction)action_Activity:(id)sender
{
    NSLog(@"Acvitity clicked");
    
    if ([_delegate respondsToSelector:@selector(MyProfileInfoHeaderViewDidSelectActivity:)]) {
        
        [_delegate MyProfileInfoHeaderViewDidSelectActivity:sender];
        
        [Common addPopAnimationToLayer:self.btn_Activity.layer withBounce:0.2 damp:0.080];
        
        [UIView animateWithDuration:0.7 animations:^{
            
            [self.btn_Activity setTitleColor:kActiveButtonColor forState:UIControlStateNormal];
            self.btn_Activity.titleLabel.font = kActiveButtonFont;
            
            [self.btn_MyPosts setTitleColor:kInActiveButtonColor forState:UIControlStateNormal];
            self.btn_MyPosts.titleLabel.font = kInActiveButtonFont;
            
        } completion:^(BOOL finished) {
                        
        }];
    }
    
}

- (IBAction)action_ShowFullAvatar:(id)sender {
    if (kAllowUserShowFullAvatar && [_delegate respondsToSelector:@selector(MyProfileInfoHeaderViewDidClickShowAvatar:)]) {
        [_delegate MyProfileInfoHeaderViewDidClickShowAvatar:sender];
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    CGPoint pointInChangeImageBtn = [self convertPoint:point toView:self.btn_ChangeUserAvatar];
    if ([self.btn_ChangeUserAvatar pointInside:pointInChangeImageBtn withEvent:event])
        return self.btn_ChangeUserAvatar;
    
    CGPoint pointInEditNameBtn = [self convertPoint:point toView:self.btn_EditUserName];
    if ([self.btn_EditUserName pointInside:pointInEditNameBtn withEvent:event])
        return self.btn_EditUserName;
    
    CGPoint pointInMyPostsBtn = [self convertPoint:point toView:self.btn_MyPosts];
    if ([self.btn_MyPosts pointInside:pointInMyPostsBtn withEvent:event])
        return self.btn_MyPosts;
    
    CGPoint pointInActivityBtn = [self convertPoint:point toView:self.btn_Activity];
    if ([self.btn_Activity pointInside:pointInActivityBtn withEvent:event])
        return self.btn_Activity;
    
    CGPoint pointInShowFullAvatarBtn = [self convertPoint:point toView:self.btn_ShowFullAvatar];
    if ([self.btn_ShowFullAvatar pointInside:pointInShowFullAvatarBtn withEvent:event])
        return self.btn_ShowFullAvatar;
    
//    CGPoint pointInButton = [self convertPoint:point toView:self.btn_newPost];
//    
//    if ([self.btn_newPost pointInside:pointInButton withEvent:event])
//        return self.btn_newPost;
//    
//    if ([self.btn_newPost pointInside:point withEvent:event] && !self.hidden)
//        return self.btn_newPost;
    
    if (self.tf_UserName.isEditing) {
        return self.touchBeganView;
    } else {
        return nil;
    }

}
@end
