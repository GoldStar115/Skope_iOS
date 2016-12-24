//
//  MainViewController.h
//  Skope
//
//  Created by Nguyen Truong Luu on 10/20/15.
//  Copyright © 2015 CHAU HUYNH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserListVC.h"
#import "PostListVC.h"
#import "HomeVC.h"
#import "ProfileVC.h"
#import "ChatViewController.h"
#import "ChatViewNavigationController.h"


typedef NS_ENUM(NSUInteger, PageViewControllerType) {
    
    PageViewControllerTypeChatView,
    PageViewControllerTypeUserProfile,
    PageViewControllerTypeUserList,
    PageViewControllerTypeHomeView,
    PageViewControllerTypePostList,
    PageViewControllerTypeCount
};


@interface MainViewController : UIViewController

@property (nonatomic, weak) HomeVC *homeViewController;
@property (nonatomic, weak) UserListVC *listUsersViewController;
@property (nonatomic, assign) PageViewControllerType currentViewControllerType;
@property (nonatomic, assign) PageViewControllerType nextViewControllerType;
@end
