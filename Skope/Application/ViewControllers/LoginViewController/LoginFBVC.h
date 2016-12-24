//
//  LoginFBVC.h
//  Skope
//
//  Created by Huynh Phong Chau on 2/28/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AuthenFacebook.h"
#import "AuthenLinkedIn.h"
#import <SVWebViewController/SVModalWebViewController.h>

@interface LoginFBVC : ADTransitioningViewController <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *lbl_containerView;
@property (weak, nonatomic) IBOutlet UIView *btn_containerView;
@property (weak, nonatomic) IBOutlet UIImageView *background_imageView;

@property (weak, nonatomic) IBOutlet UIView *agreeTextContainerView;


@end
