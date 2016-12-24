//
//  MyProfileInfoHeaderView.m
//  BLKFlexibleHeightBar Demo
//
//  Created by Bryan Keller on 2/19/15.
//  Copyright (c) 2015 Bryan Keller. All rights reserved.
//

#import "OtherUserProfileInfoHeaderView.h"
#import "UIButtonLeftIcon.h"

#define kActiveButtonColor              [UIColor colorWithRed:21.0/255 green:143.0/255 blue:191.0/255 alpha:1.0]
#define kInActiveButtonColor            [UIColor colorWithRed:170.0/255 green:170.0/255 blue:170.0/255 alpha:1.0]

#define kActiveButtonFont               [UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0f]
#define kInActiveButtonFont             [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0f]

#define kSendMSGButtonFont              [UIFont fontWithName:@"HelveticaNeue" size:15.0f]
#define kOtherUserNameTextFieldFont     [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0f]

@implementation OtherUserProfileInfoHeaderView

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
    self.minimumBarHeight = 0.0;   
    
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
    
    
    // Add and configure send message Button
    
    UIButton *sendMSGBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 135.0, 34.0)];
    sendMSGBtn.titleLabel.font = kSendMSGButtonFont;
    [sendMSGBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sendMSGBtn setTitle:@"Send Message" forState:UIControlStateNormal];
    [sendMSGBtn setBackgroundColor:APP_COMMON_GREEN_COLOR];
    [sendMSGBtn.layer setCornerRadius:17.0];
    
    BLKFlexibleHeightBarSubviewLayoutAttributes *initialSendMSGBtnLayoutAttributes = [[BLKFlexibleHeightBarSubviewLayoutAttributes alloc] init];
    initialSendMSGBtnLayoutAttributes.size = CGSizeMake(135.0, 34.0);//[changeAvatarBtn sizeThatFits:CGSizeZero];
    initialSendMSGBtnLayoutAttributes.center = CGPointMake(self.frame.size.width*0.5, self.maximumBarHeight-(80.0 + CGRectGetHeight(sendMSGBtn.bounds)/2));
    
    BLKFlexibleHeightBarSubviewLayoutAttributes *midwaySendMSGBtnLayoutAttributes = [[BLKFlexibleHeightBarSubviewLayoutAttributes alloc] initWithExistingLayoutAttributes:initialSendMSGBtnLayoutAttributes];
    midwaySendMSGBtnLayoutAttributes.center = CGPointMake(self.frame.size.width*0.5, (self.maximumBarHeight-self.minimumBarHeight)*0.4+self.minimumBarHeight-(80.0 + CGRectGetHeight(sendMSGBtn.bounds)/2));
    midwaySendMSGBtnLayoutAttributes.alpha = 0.5;
    
    
    BLKFlexibleHeightBarSubviewLayoutAttributes *finalSendMSGBtnLayoutAttributes = [[BLKFlexibleHeightBarSubviewLayoutAttributes alloc] initWithExistingLayoutAttributes:midwaySendMSGBtnLayoutAttributes];
    finalSendMSGBtnLayoutAttributes.center = CGPointMake(self.frame.size.width*0.5, self.minimumBarHeight-(80.0 + CGRectGetHeight(sendMSGBtn.bounds)/2));
    finalSendMSGBtnLayoutAttributes.alpha = 0.0;
    
    [sendMSGBtn addLayoutAttributes:initialSendMSGBtnLayoutAttributes forProgress:0.0];
    [sendMSGBtn addLayoutAttributes:midwaySendMSGBtnLayoutAttributes forProgress:0.6];
    [sendMSGBtn addLayoutAttributes:finalSendMSGBtnLayoutAttributes forProgress:1.0];
    
    [sendMSGBtn addTarget:self action:@selector(action_SendMSG:) forControlEvents:UIControlEventTouchUpInside];
    sendMSGBtn.showsTouchWhenHighlighted = YES;
    
    self.btn_SendMessage = sendMSGBtn;
    
    [self addSubview:sendMSGBtn];
    
    
    // Add UserName textField
    
    UILabel *lbl_UserName = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 280.0, 24.0)];
    lbl_UserName.font = kOtherUserNameTextFieldFont;
    lbl_UserName.textColor = [UIColor blackColor];
    lbl_UserName.textAlignment = NSTextAlignmentCenter;
    lbl_UserName.text = @"";
    
    BLKFlexibleHeightBarSubviewLayoutAttributes *initialuserNameLblLayoutAttributes = [[BLKFlexibleHeightBarSubviewLayoutAttributes alloc] init];
    initialuserNameLblLayoutAttributes.size = CGSizeMake(280.0, 40.0); //[userNameTfl sizeThatFits:CGSizeZero];
    initialuserNameLblLayoutAttributes.center = CGPointMake(self.frame.size.width*0.5, self.maximumBarHeight-(15.0 + CGRectGetHeight(lbl_UserName.bounds)/2));
    
    
    BLKFlexibleHeightBarSubviewLayoutAttributes *midwayuserNameLblLayoutAttributes = [[BLKFlexibleHeightBarSubviewLayoutAttributes alloc] initWithExistingLayoutAttributes:initialuserNameLblLayoutAttributes];
    midwayuserNameLblLayoutAttributes.center = CGPointMake(self.frame.size.width*0.5, (self.maximumBarHeight-self.minimumBarHeight)*0.4+self.minimumBarHeight-(15.0 + CGRectGetHeight(lbl_UserName.bounds)/2));
    
    
    BLKFlexibleHeightBarSubviewLayoutAttributes *finaluserNameLblLayoutAttributes = [[BLKFlexibleHeightBarSubviewLayoutAttributes alloc] initWithExistingLayoutAttributes:midwayuserNameLblLayoutAttributes];
    finaluserNameLblLayoutAttributes.center = CGPointMake(self.frame.size.width*0.5, self.minimumBarHeight-(15.0 + CGRectGetHeight(lbl_UserName.bounds)/2));
    
    [lbl_UserName addLayoutAttributes:initialuserNameLblLayoutAttributes forProgress:0.0];
    [lbl_UserName addLayoutAttributes:midwayuserNameLblLayoutAttributes forProgress:0.6];
    [lbl_UserName addLayoutAttributes:finaluserNameLblLayoutAttributes forProgress:1.0];
    
    self.lbl_UserName = lbl_UserName;
    
    [self addSubview:lbl_UserName];
    
    
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


- (IBAction)action_SendMSG:(id)sender
{
    NSLog(@"Send MSG clicked");
    
    if ([_delegate respondsToSelector:@selector(OtherUserProfileInfoHeaderViewDidClickSendMSG:)]) {
        [_delegate OtherUserProfileInfoHeaderViewDidClickSendMSG:sender];
        
        //[Common addPopAnimationToLayer:self.btn_SendMessage.layer withBounce:0.2 damp:0.080];
    }
    
}

- (IBAction)action_ShowFullAvatar:(id)sender {
    
    if (kAllowUserShowFullAvatar && [_delegate respondsToSelector:@selector(OtherUserProfileInfoHeaderViewDidClickShowAvatar:)]) {
        [_delegate OtherUserProfileInfoHeaderViewDidClickShowAvatar:sender];
    }
    
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    CGPoint pointInChangeImageBtn = [self convertPoint:point toView:self.btn_SendMessage];
    if ([self.btn_SendMessage pointInside:pointInChangeImageBtn withEvent:event])
        return self.btn_SendMessage;
    
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
    
    return nil;

}
@end
