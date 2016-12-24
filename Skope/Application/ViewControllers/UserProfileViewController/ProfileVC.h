//
//  ProfileVC.h
//  Skope
//
//  Created by Huynh Phong Chau on 3/2/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProfileInfoCell.h"
#import "ProfilePostCell.h"
#import <MediaPlayer/MediaPlayer.h>

@class ProfileVC;
@protocol ProfileDelegate <NSObject>

- (void) profileActionBack;
- (void) profileSendMessage:(NSString*)groupID receiverEmail:(NSString*)receiverEmail;

@end

@interface ProfileVC : ADTransitioningViewController {
    BOOL            isrefreshing;
    BOOL            isloading;
}

@property (nonatomic, assign)id<ProfileDelegate> delegate;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *containerView;

- (IBAction)actionBack:(id)sender;

- (void)setUserProfileInfo:(NSDictionary *)userProfileInfo;
- (NSDictionary*)getUserProfileInfo;

@end
