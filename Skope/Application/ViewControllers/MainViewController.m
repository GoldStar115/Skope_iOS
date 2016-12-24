//
//  MainViewController.m
//  Skope
//
//  Created by Nguyen Truong Luu on 10/20/15.
//  Copyright © 2015 CHAU HUYNH. All rights reserved.
//

#import "MainViewController.h"
#import "LoginFBVC.h"
#import <ISDiskCache/ISDiskCache.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "messages.h"

@interface MainViewController () <UIPageViewControllerDelegate,UIPageViewControllerDataSource,ChatViewDelegate,UserListDelegate, PostListDelegate, HomeListDelegate, ProfileDelegate>


@property (nonatomic, strong) NSDictionary *pageViewControllersClasses;
@property (nonatomic, strong) NSDictionary *pageViewControllerStoryboardIdentifier;
//@property (nonatomic, strong) UIViewController* currentViewController;

@property (nonatomic, strong) UIPageViewController* _pageViewController;
@property (nonatomic, strong) LoginFBVC *_loginVC;

@end

@implementation MainViewController


- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initialize];
    }
    return self;
}


- (void)initialize
{
    
    /*
     #if !defined(STORYBOARD)
     self.pageViewControllersClasses = @{
     @(PageViewControllerTypeChatView) : [ChatViewNavigationController class],
     @(PageViewControllerTypeUserProfile) : [ProfileVC class],
     @(PageViewControllerTypeUserList) : [UserListVC class],
     @(PageViewControllerTypeHomeView) : [HomeVC class],
     @(PageViewControllerTypePostList) : [PostListVC class]
     };
     #else
     */
    
    self.pageViewControllerStoryboardIdentifier = @{
                                                    @(PageViewControllerTypeChatView) : @"VIEW_CHAT",
                                                    @(PageViewControllerTypeUserProfile) : @"VIEW_PROFILE",
                                                    @(PageViewControllerTypeUserList) : @"VIEW_USER_LIST",
                                                    @(PageViewControllerTypeHomeView) : @"VIEW_HOME",
                                                    @(PageViewControllerTypePostList) : @"VIEW_POST_LIST",
                                                    };
    //#endif
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if (kAllowAutoDetectConnectionAndRefreshData && [NTLReachabilityManager isUnreachable]) {
            [[AppDelegate sharedReachabilityAlert] showInView:[[[UIApplication sharedApplication] delegate] window]];
        }
    });
    
    
    if ([[UserDefault currentUser] isLoggedIn] && [PFUser currentUser]) {

        [self showHomeViewController:NO];
        
    } else {
        
        [self showLoginViewController:NO];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainVCLogout) name:NOTIFICATION_USER_LOGGED_OUT object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainVCLogin) name:NOTIFICATION_USER_LOGGED_IN object:nil];
}


- (IBAction)mainVCLogin {
    [self showHomeViewController:YES];
}


- (IBAction) mainVCLogout {
    
    [self showLoginViewController:YES];
    
    NSString *access_token = [UserDefault currentUser].server_access_token;
    NSDictionary *request_param = @{@"access_token":access_token,
                                    };
    
    AFHTTPRequestOperationManager *manager = [Common AFHTTPRequestOperationManagerReturn];
    [manager DELETE:URL_SERVER_API(API_USER_LOGOUT) parameters:request_param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [[AuthenFacebook sharedAuthenFacebook] clearAllDataAndLogoutAllAccount];
            [AppDelegate updateAppIconBadgedNumber];
        });
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [[AuthenFacebook sharedAuthenFacebook] clearAllDataAndLogoutAllAccount];
            [AppDelegate updateAppIconBadgedNumber];
        });
        
    }];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UIPAGEVIEW CONTROLLER

-(UIViewController *)viewControllerAtIndex:(NSUInteger)index
{
    return [self viewControllerForPageType:index];
    
    //return myViewControllers[index];
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController
     viewControllerBeforeViewController:(UIViewController *)viewController
{
    switch ([self typeForCurrentViewController:viewController]) {
        case PageViewControllerTypeUserProfile:
        {
            ProfileVC *profileVC = (ProfileVC *)viewController;
            ChatViewNavigationController *chatNav = (ChatViewNavigationController*) [self viewControllerForPageType:PageViewControllerTypeChatView];
            ChatViewController *chatVC = (ChatViewController *)[chatNav topViewController];
            NSDictionary *userProfileInfo = [profileVC getUserProfileInfo];
            [chatVC clearOldData];
            chatVC.fromVCtype = FromUserProfileVC;
            if (userProfileInfo) {
                chatVC.fromVCtype = FromUserProfileVC;
                NSString *groupId = [[ISDiskCache sharedCache] objectForKey:[NSString stringWithFormat:@"%@_chat_email-%@",[UserDefault currentUser].email,userProfileInfo[@"email"]]];
                if (groupId) {
                    //Have groupdID
                    [chatVC setGroupId:groupId];
                    [chatVC setReceiverEmail:userProfileInfo[@"email"]];
                } else {
                    
                    //Query for groupdID
                    PFUser *user1 = [PFUser currentUser];
                    PFQuery *query = [PFUser query];
                    [query whereKey:@"emailCopy" equalTo:userProfileInfo[@"email"]];
                    
                    [query getFirstObjectInBackgroundWithBlock:^(PFObject *PF_NULLABLE_S object,  NSError *PF_NULLABLE_S error){
                        PFUser *user2 = (PFUser *)object;
                        if (!user2) {
                            //NSLog(@"The getFirstObject request failed.");
                        } else {
                            // The find succeeded.
                            //NSLog(@"Successfully retrieved the object.");
                            
                            NSString *groupId = /*([user1.objectId compare:user2.objectId] < 0) ? [NSString stringWithFormat:@"%@%@", user1.objectId, user2.objectId] : [NSString stringWithFormat:@"%@%@", user2.objectId, user1.objectId];//*/StartPrivateChat(user1, user2);
                            
                            [chatVC setGroupId:groupId];
                            [chatVC setReceiverEmail:user2[PF_USER_EMAILCOPY]];
                            //Cache groupdId
                            [[ISDiskCache sharedCache] setObject:groupId forKey:[NSString stringWithFormat:@"%@_chat_email-%@",[UserDefault currentUser].email,userProfileInfo[@"email"]]];
                            //[[ISDiskCache sharedCache] setObject:groupId forKey:[NSString stringWithFormat:@"%@_chat_email-%@",[UserDefault currentUser].email,user2[PF_MESSAGES_LASTUSER_EMAIL]]];
                        }
                    }];
                }
            } else {
                return nil;
            }
            return chatNav;
        }
            break;
        case PageViewControllerTypeUserList:
        {
            MainViewController *mainVC = (MainViewController *)[[(AppDelegate*)[[UIApplication sharedApplication] delegate] window] rootViewController];
            UserListVC *usersVC = (UserListVC*)viewController;
            ProfileVC *profileVC = (ProfileVC*)[self viewControllerForPageType:PageViewControllerTypeUserProfile];
            if ([usersVC arrayUsers].count == 0) {
                
                
                [mainVC homeViewController].selectedUserProfile = nil;
                
                return nil;
            } else {
                if (![[usersVC arrayUsers] containsObject:[mainVC homeViewController].selectedUserProfile]) {
                    [mainVC homeViewController].selectedUserProfile = [[usersVC arrayUsers] firstObject];
                }
                [profileVC setUserProfileInfo:[mainVC homeViewController].selectedUserProfile];
            }
            return profileVC;
        }
            break;
        case PageViewControllerTypeHomeView:
        {
            HomeVC *homeVC = (HomeVC*)viewController;
            UserListVC *userListVC = (UserListVC*)[self viewControllerForPageType:PageViewControllerTypeUserList];
            userListVC.regionMap = [homeVC recalculatedRadiusUpdate];
            return userListVC;
        }
        case PageViewControllerTypePostList: {
            HomeVC *homeVC = (HomeVC*)[self viewControllerForPageType:PageViewControllerTypeHomeView];
            return homeVC;
        }
            break;
        default:
            return nil;
            break;
    }
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerAfterViewController:(UIViewController *)viewController
{
    MainViewController *mainVC = (MainViewController *)[[(AppDelegate*)[[UIApplication sharedApplication] delegate] window] rootViewController];
    switch ([self typeForCurrentViewController:viewController]) {
        case PageViewControllerTypeChatView:
        {
            //ChatViewNavigationController *chatNav = (ChatViewNavigationController*) viewController;
            //ChatView *chatVC = chatNav.topViewController;
            ProfileVC *profileVC = (ProfileVC*)[self viewControllerForPageType:PageViewControllerTypeUserProfile];
            [profileVC setUserProfileInfo:[mainVC homeViewController].selectedUserProfile];
            return profileVC;
        }
            break;
        case PageViewControllerTypeUserProfile:
        {
            //ProfileVC *profileVC = (ProfileVC*)viewController;
            UserListVC *userListVC = (UserListVC*)[self viewControllerForPageType:PageViewControllerTypeUserList];
            [userListVC setRegionMap:[[mainVC homeViewController] recalculatedRadiusUpdate]];
            return userListVC;
        }
            break;
        case PageViewControllerTypeUserList:
        {
            //UserListVC *userListVC = (UserListVC*)viewController;
            HomeVC *homeVC = (HomeVC*)[self viewControllerForPageType:PageViewControllerTypeHomeView];
            return homeVC;
        }
            break;
        case PageViewControllerTypeHomeView:
        {
            //HomeVC *homeVC = (HomeVC*)viewController;
            PostListVC *postlistVC = (PostListVC*)[self viewControllerForPageType:PageViewControllerTypePostList];
            postlistVC.regionMap = [[mainVC homeViewController] recalculatedRadiusUpdate];
            return postlistVC;
        }
            break;
        default:
            return nil;
            break;
    }
}

-(NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return self.currentViewControllerType;
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    
    if (completed) {
        
        self.currentViewControllerType = self.nextViewControllerType;
        
        switch ([self typeForCurrentViewController:previousViewControllers.firstObject]) {
            case PageViewControllerTypeChatView:
            {
                
            }
                break;
            case PageViewControllerTypeUserProfile:
            {
                
            }
                break;
            case PageViewControllerTypeUserList:
            {
                UserListVC *userListVC = (UserListVC*)previousViewControllers.firstObject;
            }
                break;
            case PageViewControllerTypeHomeView:
            {
                
            }
                break;
            case PageViewControllerTypePostList:
            {
                PostListVC *postlistVC = (PostListVC*)previousViewControllers.firstObject;
            }
                break;
                
            default:
                break;
        }
    }
    
    self.nextViewControllerType = PageViewControllerTypeChatView;
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers {
    
    self.nextViewControllerType = [self typeForCurrentViewController:pendingViewControllers.firstObject];
    
    switch (self.nextViewControllerType) {
            
        case PageViewControllerTypeChatView:
        {
            
        }
            break;
        case PageViewControllerTypeUserProfile:
        {
            
        }
            break;
        case PageViewControllerTypeUserList:
        {
            MainViewController *mainVC = (MainViewController *)[[(AppDelegate*)[[UIApplication sharedApplication] delegate] window] rootViewController];
            UserListVC *userListVC = (UserListVC*)pendingViewControllers.firstObject;
            [userListVC setRegionMap:[[mainVC homeViewController] recalculatedRadiusUpdate]];
        }
            break;
        case PageViewControllerTypeHomeView:
        {
            
        }
            break;
        case PageViewControllerTypePostList:
        {
            //PostListVC *postlistVC = (PostListVC*)previousViewControllers.firstObject;
            //[postlistVC stopReloadUserListTimer];
        }
            break;
            
        default:
            break;
    }
    
    /*
     if (pendingViewControllers.count > 0)
     {
     if ([self typeForCurrentViewController:pendingViewControllers.firstObject] == PageViewControllerTypeChatView) {
     NSDictionary *userProfileInfo = [((ProfileVC*)self.currentViewController) getUserProfileInfo];
     ChatViewNavigationController *chatNav = (ChatViewNavigationController*)pendingViewControllers.firstObject;
     ChatView *chatView = (ChatView *)chatNav.topViewController;
     [chatView clearOldData];
     if (userProfileInfo) {
     chatView.fromVCtype = FromUserProfileVC;
     chatView.emailUser = userProfileInfo[@"email"];
     
     NSLog(@"userProfileInfo: %@",userProfileInfo);
     
     NSString *groupId = [[ISDiskCache sharedCache] objectForKey:[NSString stringWithFormat:@"%@_chat_email-%@",[UserDefault currentUser].email,userProfileInfo[@"email"]]];
     
     if (groupId) {
     //Have groupdID
     [chatView setGroupId:groupId];
     } else {
     
     //Query for groupdID
     PFUser *user1 = [PFUser currentUser];
     PFQuery *query = [PFUser query];
     [query whereKey:@"emailCopy" equalTo:userProfileInfo[@"email"]];
     
     [query getFirstObjectInBackgroundWithBlock:^(PFObject *PF_NULLABLE_S object,  NSError *PF_NULLABLE_S error){
     PFUser *user2 = (PFUser *)object;
     if (!user2) {
     NSLog(@"The getFirstObject request failed.");
     } else {
     // The find succeeded.
     NSLog(@"Successfully retrieved the object.");
     
     NSString *groupId = //([user1.objectId compare:user2.objectId] < 0) ? [NSString stringWithFormat:@"%@%@", user1.objectId, user2.objectId] : [NSString stringWithFormat:@"%@%@", user2.objectId, user1.objectId];//
     StartPrivateChat(user1, user2);
     
     [chatView setGroupId:groupId];
     //Cache groupdId
     [[ISDiskCache sharedCache] setObject:groupId forKey:[NSString stringWithFormat:@"%@_chat_email-%@",[UserDefault currentUser].email,userProfileInfo[@"email"]]];
     //[[ISDiskCache sharedCache] setObject:groupId forKey:[NSString stringWithFormat:@"%@_chat_email-%@",[UserDefault currentUser].email,user2[PF_MESSAGES_LASTUSER_EMAIL]]];
     }
     }];
     }
     } else {
     NSLog(@"Have no user profile");
     }
     chatView.fromVCtype = FromUserProfileVC;
     }
     
     if (self.currentPageType == PageViewControllerTypeHomeView) {
     HomeVC *homeVC = (HomeVC *)self.currentViewController;
     CGFloat regionMap = [homeVC recalculatedRadiusUpdate];
     PageViewControllerType nextType = [self typeForCurrentViewController:pendingViewControllers.firstObject];
     if (nextType == PageViewControllerTypeUserList) {
     UserListVC *userListVC = (UserListVC*)pendingViewControllers.firstObject;
     userListVC.regionMap = regionMap;
     }
     if (nextType == PageViewControllerTypePostList) {
     PostListVC *postListVC = (PostListVC*)pendingViewControllers.firstObject;
     postListVC.regionMap = regionMap;
     }
     }
     }
     
     if (pendingViewControllers.count > 0 && [pendingViewControllers.firstObject isKindOfClass:[ProfileVC class]]) {
     
     }
     
     self.currentViewController = pendingViewControllers.firstObject;
     self.currentPageType = [self typeForCurrentViewController:self.currentViewController];
     */
}

#pragma mark - USER_POST_HOME DELEGATE

- (void) messageActionBack {
    MainViewController *mainVC = (MainViewController *)[[(AppDelegate*)[[UIApplication sharedApplication] delegate] window] rootViewController];
    ProfileVC *profileVC = (ProfileVC*)[self viewControllerForPageType:PageViewControllerTypeUserProfile];
    [profileVC setUserProfileInfo:[mainVC homeViewController].selectedUserProfile];
    
    UIPageViewController *pageViewVC = ([self.childViewControllers count] > 0 ? self.childViewControllers[0] : nil);
    if (pageViewVC) {
        
        __weak __typeof(self)weakSelf = self;
        __strong __typeof__(self) strongSelf = weakSelf;
        
        [pageViewVC setViewControllers:@[profileVC]
                                          direction:UIPageViewControllerNavigationDirectionForward
                                           animated:YES completion:^(BOOL finished) {
                                               strongSelf.currentViewControllerType = PageViewControllerTypeUserProfile;
                                           }];
        
    }

}

- (void) userListActionBack {
    HomeVC *homeVC = (HomeVC*)[self viewControllerForPageType:PageViewControllerTypeHomeView];
    
    UIPageViewController *pageViewVC = ([self.childViewControllers count] > 0 ? self.childViewControllers[0] : nil);
    if (pageViewVC) {
        
        __weak __typeof(self)weakSelf = self;
        __strong __typeof__(self) strongSelf = weakSelf;
        
        [pageViewVC setViewControllers:@[homeVC]
                                          direction:UIPageViewControllerNavigationDirectionForward
                                           animated:YES completion:^(BOOL finished) {
                                               strongSelf.currentViewControllerType = PageViewControllerTypeHomeView;
                                           }];
    }

}

- (void) postListActionBack {
    HomeVC *homeVC = (HomeVC*)[self viewControllerForPageType:PageViewControllerTypeHomeView];
    
    UIPageViewController *pageViewVC = ([self.childViewControllers count] > 0 ? self.childViewControllers[0] : nil);
    if (pageViewVC) {
        
        __weak __typeof(self)weakSelf = self;
        __strong __typeof__(self) strongSelf = weakSelf;
        
        [pageViewVC setViewControllers:@[homeVC]
                                          direction:UIPageViewControllerNavigationDirectionReverse
                                           animated:YES completion:^(BOOL finished) {
                                               strongSelf.currentViewControllerType = PageViewControllerTypeHomeView;
                                           }];
    }
 
}

- (void) profileActionBack{
    MainViewController *mainVC = (MainViewController *)[[(AppDelegate*)[[UIApplication sharedApplication] delegate] window] rootViewController];
    UserListVC * usersVC = (UserListVC*)[self viewControllerForPageType:PageViewControllerTypeUserList];
    [usersVC setRegionMap:[[mainVC homeViewController] recalculatedRadiusUpdate]];
    
    UIPageViewController *pageViewVC = ([self.childViewControllers count] > 0 ? self.childViewControllers[0] : nil);
    if (pageViewVC) {
        
        __weak __typeof(self)weakSelf = self;
        __strong __typeof__(self) strongSelf = weakSelf;
        
        [pageViewVC setViewControllers:@[usersVC]
                                          direction:UIPageViewControllerNavigationDirectionForward
                                           animated:YES completion:^(BOOL finished) {
                                               
                                               strongSelf.currentViewControllerType = PageViewControllerTypeUserList;
                                               
                                           }];
    }
  
}

//Add by Nguyen Truong Luu

- (void) profileSendMessage:(NSString*)groupID receiverEmail:(NSString*)receiverEmail
{
    //if (self.currentViewControllerType != PageViewControllerTypeChatView) {
    
    ChatViewNavigationController *chatNav = (ChatViewNavigationController*)[self viewControllerForPageType:PageViewControllerTypeChatView];
    ChatViewController *chatView = (ChatViewController *)chatNav.topViewController;
    chatView.fromVCtype = FromUserProfileVC;
    
    UIPageViewController *pageViewVC = ([self.childViewControllers count] > 0 ? self.childViewControllers[0] : nil);
    if (pageViewVC) {
        
        __weak __typeof(self)weakSelf = self;
        __strong __typeof__(self) strongSelf = weakSelf;
        
        [pageViewVC setViewControllers:@[chatNav]
                                          direction:UIPageViewControllerNavigationDirectionReverse
                                           animated:YES completion:^(BOOL finished) {
                                               strongSelf.currentViewControllerType = PageViewControllerTypeChatView;
                                           }];
    }
    
    

    
    if (groupID) {
        
        [chatView setGroupId:groupID];
        
        [chatView setReceiverEmail:receiverEmail];
        
    } else if (receiverEmail) {
        
        [Common showLoadingViewGlobal:nil];
        
        PFUser *user1 = [PFUser currentUser];
        
        
        PFQuery *query = [PFUser query];
        [query whereKey:@"emailCopy" equalTo:receiverEmail];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *PF_NULLABLE_S object,  NSError *PF_NULLABLE_S error){
            
            PFUser *user2 = (PFUser *)object;
            
            if (!user2) {
                
                [Common hideLoadingViewGlobal];
                
                NSLog(@"The getFirstObject request failed.");
                
            } else {
                
                //===The find succeeded.
                
                NSLog(@"Successfully retrieved the object.");
                
                NSString *server_groupId = //([user1.objectId compare:user2.objectId] < 0) ? [NSString stringWithFormat:@"%@%@", user1.objectId, user2.objectId] : [NSString stringWithFormat:@"%@%@", user2.objectId, user1.objectId];
                StartPrivateChat(user1, user2);
                
                //===Changed by Nguyen Truong Luu
                
                [chatView setGroupId:server_groupId];
                
                [chatView setReceiverEmail:receiverEmail];
                
                //===Cache groupdId
                
                [[ISDiskCache sharedCache] setObject:server_groupId forKey:[NSString stringWithFormat:@"%@_chat_email-%@",[UserDefault currentUser].email,receiverEmail]];
                
                //[[ISDiskCache sharedCache] setObject:groupId forKey:[NSString stringWithFormat:@"%@_chat_email-%@",[UserDefault currentUser].email,user2[PF_MESSAGES_LASTUSER_EMAIL]]];
            }
        }];
        
    } else {
        
    }
    //}
    
}

- (void)chatViewActionBack:(ChatViewController*)chatView {
    
    /*
     if (chatView.userProfileInfo) {
     //Have profile => private chat between two people
     NSDictionary *dicPf = chatView.userProfileInfo;
     
     [self.pageViewController setViewControllers:@[p1]
     direction:UIPageViewControllerNavigationDirectionForward
     animated:YES completion:nil];
     p1.userProfileInfo = dicPf;
     
     } else {
     //Have no profile => chat in group
     }
     */
    MainViewController *mainVC = (MainViewController *)[[(AppDelegate*)[[UIApplication sharedApplication] delegate] window] rootViewController];
    ProfileVC *profileVC = (ProfileVC*)[self viewControllerForPageType:PageViewControllerTypeUserProfile];
    [profileVC setUserProfileInfo:[mainVC homeViewController].selectedUserProfile];
    
    UIPageViewController *pageViewVC = ([self.childViewControllers count] > 0 ? self.childViewControllers[0] : nil);
    if (pageViewVC) {
        
        __weak __typeof(self)weakSelf = self;
        __strong __typeof__(self) strongSelf = weakSelf;
        
        [pageViewVC setViewControllers:@[profileVC]
                                          direction:UIPageViewControllerNavigationDirectionForward
                                           animated:YES completion:^(BOOL finished) {
                                               strongSelf.currentViewControllerType = PageViewControllerTypeUserProfile;
                                           }];
    }

}

- (void) chatViewActionBlockUserSuccess:(ChatViewController *)chatView status:(NSString *)status {
    
    MainViewController *mainVC = (MainViewController *)[[(AppDelegate*)[[UIApplication sharedApplication] delegate] window] rootViewController];
    UserListVC * usersVC = (UserListVC*)[self viewControllerForPageType:PageViewControllerTypeUserList];
    [usersVC setRegionMap:[[mainVC homeViewController] recalculatedRadiusUpdate]];
    
    UIPageViewController *pageViewVC = ([self.childViewControllers count] > 0 ? self.childViewControllers[0] : nil);
    if (pageViewVC) {
        
        __weak __typeof(self)weakSelf = self;
        __strong __typeof__(self) strongSelf = weakSelf;
        
        [pageViewVC setViewControllers:@[usersVC]
                                          direction:UIPageViewControllerNavigationDirectionForward
                                           animated:YES completion:^(BOOL finished) {
                                               [SVProgressHUD showInfoWithStatus:status];
                                               strongSelf.currentViewControllerType = PageViewControllerTypeUserList;
                                           }];
        
    }

}

//================================

- (void) homeListActionShowUser:(CGFloat)regionMap {
    
    UserListVC *usersVC = (UserListVC*)[self viewControllerForPageType:PageViewControllerTypeUserList];
    [usersVC setRegionMap:regionMap];
    
    UIPageViewController *pageViewVC = ([self.childViewControllers count] > 0 ? self.childViewControllers[0] : nil);
    if (pageViewVC) {
        
        __weak __typeof(self)weakSelf = self;
        __strong __typeof__(self) strongSelf = weakSelf;
        
        [pageViewVC setViewControllers:@[usersVC]
                                          direction:UIPageViewControllerNavigationDirectionReverse
                                           animated:YES completion:^(BOOL finished) {
                                               strongSelf.currentViewControllerType = PageViewControllerTypeUserList;
                                           }];
        
    }
}

- (void) homeListActionShowPost:(CGFloat)regionMap {
    
    PostListVC *postsVC = (PostListVC*)[self viewControllerForPageType:PageViewControllerTypePostList];
    [postsVC setRegionMap:regionMap];
    
    UIPageViewController *pageViewVC = ([self.childViewControllers count] > 0 ? self.childViewControllers[0] : nil);
    if (pageViewVC) {
        
        __weak __typeof(self)weakSelf = self;
        __strong __typeof__(self) strongSelf = weakSelf;
        
        [pageViewVC setViewControllers:@[postsVC]
                                          direction:UIPageViewControllerNavigationDirectionForward
                                           animated:YES completion:^(BOOL finished) {
                                               strongSelf.currentViewControllerType = PageViewControllerTypePostList;
                                           }];
    }
}

- (void) userListActionGoProfile:(NSDictionary *)userProfileInto {
    MainViewController *mainVC = (MainViewController *)[[(AppDelegate*)[[UIApplication sharedApplication] delegate] window] rootViewController];
    ProfileVC *profileVC = (ProfileVC *)[self viewControllerForPageType:PageViewControllerTypeUserProfile];
    [profileVC setUserProfileInfo:userProfileInto];
    [mainVC homeViewController].selectedUserProfile = userProfileInto;
    
    UIPageViewController *pageViewVC = ([self.childViewControllers count] > 0 ? self.childViewControllers[0] : nil);
    if (pageViewVC) {
        
        __weak __typeof(self)weakSelf = self;
        __strong __typeof__(self) strongSelf = weakSelf;
        
        [pageViewVC setViewControllers:@[profileVC]
                                          direction:UIPageViewControllerNavigationDirectionReverse
                                           animated:YES completion:^(BOOL finished) {
                                               strongSelf.currentViewControllerType = PageViewControllerTypeUserProfile;
                                           }];
    }
}

- (void) userListActionPassData:(NSDictionary *)dicPf {
    //p1.userProfileInfo = dicPf;
}

- (void) homePostDone:(CGFloat)regionMap {
    
    PostListVC *postlistVC = (PostListVC*)[self viewControllerForPageType:PageViewControllerTypePostList];
    [postlistVC setRegionMap:regionMap];
    
    UIPageViewController *pageViewVC = ([self.childViewControllers count] > 0 ? self.childViewControllers[0] : nil);
    if (pageViewVC) {
        
        __weak __typeof(self)weakSelf = self;
        __strong __typeof__(self) strongSelf = weakSelf;
        
        [pageViewVC setViewControllers:@[postlistVC]
                                          direction:UIPageViewControllerNavigationDirectionForward
                                           animated:YES completion:^(BOOL finished) {
                                               strongSelf.currentViewControllerType = PageViewControllerTypePostList;
                                           }];
    }
}

#pragma mark - PageViewController's viewController init

- (PageViewControllerType)typeForCurrentViewController:(UIViewController*)viewController {
    
    if ([viewController isKindOfClass:[ChatViewNavigationController class]]) {
        return PageViewControllerTypeChatView;
    }
    if ([viewController isKindOfClass:[ProfileVC class]]) {
        return PageViewControllerTypeUserProfile;
    }
    if ([viewController isKindOfClass:[UserListVC class]]) {
        return PageViewControllerTypeUserList;
    }
    if ([viewController isKindOfClass:[HomeVC class]]) {
        return PageViewControllerTypeHomeView;
    }
    if ([viewController isKindOfClass:[PostListVC class]]) {
        return PageViewControllerTypePostList;
    }
    return PageViewControllerTypeHomeView;
}

- (UIViewController*)viewControllerForPageType:(PageViewControllerType)pageControllerType {
    
    if (pageControllerType == PageViewControllerTypeHomeView) {
        MainViewController *mainVC = (MainViewController *)[[(AppDelegate*)[[UIApplication sharedApplication] delegate] window] rootViewController];
        if (![mainVC homeViewController]) {
            //#if defined(STORYBOARD)
            HomeVC *homeVC  = [self.storyboard instantiateViewControllerWithIdentifier:self.pageViewControllerStoryboardIdentifier[@(pageControllerType)]];
            /*
             #else
             Class pageViewControllerClass = self.pageViewControllersClasses[@(pageControllerType)];
             HomeVC *homeVC = (HomeVC *)[pageViewControllerClass new];
             #endif
             */
            homeVC.delegate = self;
            [mainVC setHomeViewController:homeVC];
        }
        
        return [mainVC homeViewController];
        
    } else if (pageControllerType == PageViewControllerTypeUserList) {
        
        if (!self.listUsersViewController) {
            
            UserListVC *userlistVC = [self.storyboard instantiateViewControllerWithIdentifier:self.pageViewControllerStoryboardIdentifier[@(pageControllerType)]];
            userlistVC.delegate = self;
            self.listUsersViewController = userlistVC;
            
        }
        
        return self.listUsersViewController;
        
    } else {
        
        //#if defined(STORYBOARD)
        
        UIViewController *pageViewController;
        
        switch (pageControllerType) {
                
            case PageViewControllerTypePostList:
            {
                pageViewController = [[PostListVC alloc] initWithNibName:@"PostListVC" bundle:nil];
            }
                break;
            case PageViewControllerTypeUserProfile:
            {
                pageViewController = [[ProfileVC alloc] initWithNibName:@"ProfileVC" bundle:nil];
            }
                break;
            default:
            {
                pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:self.pageViewControllerStoryboardIdentifier[@(pageControllerType)]];
            }
                break;
        }
        
        
        //#else
        //Class pageViewControllerClass = self.pageViewControllersClasses[@(pageControllerType)];
        // UIViewController *pageViewController = (UIViewController *)[pageViewControllerClass new];
        //#endif
        switch (pageControllerType) {
            case PageViewControllerTypeChatView:
            {
                ChatViewNavigationController *chatNav = (ChatViewNavigationController*)pageViewController;
                ChatViewController *chatVC = (ChatViewController*)chatNav.topViewController;
                chatVC.delegate = self;
                
                [chatNav.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
                chatNav.navigationBar.shadowImage = [UIImage new];
                chatNav.navigationBar.barTintColor = [UIColor whiteColor];
                chatNav.navigationBar.translucent = NO;
            }
                break;
            case PageViewControllerTypeUserProfile:
            {
                ProfileVC *profileVC = (ProfileVC*)pageViewController;
                profileVC.delegate = self;
            }
                break;
            case PageViewControllerTypeHomeView:
            {
                HomeVC *homeVC = (HomeVC*)pageViewController;
                homeVC.delegate = self;
            }
                break;
            case PageViewControllerTypePostList:
            {
                PostListVC *postListVC = (PostListVC*)pageViewController;
                postListVC.delegate = self;
            }
                break;
                
            default:
                break;
        }
        
        return pageViewController;
    }
}


#pragma mark - Transitions

- (void)showHomeViewController:(BOOL)animated {
    
    self._pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    __pageViewController.delegate = self;
    __pageViewController.dataSource = self;

    __weak __typeof(self)weakSelf = self;
    __strong __typeof__(self) strongSelf = weakSelf;
    
    UIViewController* homeVC = [self viewControllerForPageType:PageViewControllerTypeHomeView];
    
    
    [self._pageViewController setViewControllers:@[homeVC]
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:NO completion:^(BOOL finished) {
                                           strongSelf.currentViewControllerType = PageViewControllerTypeHomeView;
                                       }];

    //ADTransition * animation = [[ADGhostTransition alloc] initWithDuration:1.4];
    //startAppVC.transition = animation;
    [self _transitionToChildViewController:self._pageViewController];
}

- (void)showLoginViewController:(BOOL)animated {
    
    self._loginVC = [Main_Storyboard instantiateViewControllerWithIdentifier:@"LOGIN_VC"];
    //ADTransition * animation = [[ADGhostTransition alloc] initWithDuration:1.4];
    //loginVC.transition = animation;
    [self _transitionToChildViewController:self._loginVC];
}


- (void)_transitionToChildViewController:(UIViewController *)toViewController {
    
    UIViewController *fromViewController = ([self.childViewControllers count] > 0 ? self.childViewControllers[0] : nil);
    if (toViewController == fromViewController || ![self isViewLoaded]) {
        return;
    }
    
    //  Config frame for child viewcontroller
    
    UIView *toView = toViewController.view;
    [toView setTranslatesAutoresizingMaskIntoConstraints:YES];
    toView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    toView.frame = self.view.bounds;
    
    [self addChildViewController:toViewController];
    [fromViewController willMoveToParentViewController:nil];
    //[toViewController willMoveToParentViewController:self];
    

    __weak __typeof(self)weakSelf = self;
    __strong __typeof__(self) strongSelf = weakSelf;
    
    if (!fromViewController) {
        
        //  If have no old viewcontroller
        
        [self.view addSubview:toView];
        [toViewController didMoveToParentViewController:self];

        if (toViewController == strongSelf._loginVC) {
            strongSelf._pageViewController = nil;
        } else {
            strongSelf._loginVC = nil;
        }
        
    } else {
        
        //  Use animation if have old viewcontroller
        
        //[toViewController beginAppearanceTransition:YES animated:NO];
        
        //[fromViewController willMoveToParentViewController:nil];
        
        [self transitionFromViewController:fromViewController
                          toViewController:toViewController
                                  duration:0.4
                                   options:UIViewAnimationOptionTransitionCrossDissolve
                                animations:^{
                                    //[subview1 setAlpha:0.0];
                                }
                                completion:^(BOOL finished) {
                                    
                                    //[fromViewController didMoveToParentViewController:nil];
                                    //[fromViewController.view removeFromSuperview];
                                    [fromViewController removeFromParentViewController];
                                    [toViewController didMoveToParentViewController:strongSelf];
                                    
                                    //[toViewController endAppearanceTransition];
                                    
                                    if (toViewController == strongSelf._loginVC) {
                                        strongSelf._pageViewController = nil;
                                    } else {
                                        strongSelf._loginVC = nil;
                                    }
                                    
                                }];
    }    
}



@end
