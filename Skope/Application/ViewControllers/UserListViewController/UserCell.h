//
//  usersCell.h
//  Skope
//
//  Created by CHAU HUYNH on 2/11/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"

@class UserCell;

@protocol UserCellDelegate <NSObject>

- (void)UserCell:(UserCell*)cell didClickedReportButton:(id)sender;

@end

@interface UserCell : UITableViewCell

@property (strong, nonatomic) id<UserCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIImageView    *imgView_UserAvatar;
@property (weak, nonatomic) IBOutlet UILabel        *lbl_UserName;
@property (weak, nonatomic) IBOutlet UILabel        *lbl_DistanceToMe;

- (void)fillUserInfoToView:(NSMutableDictionary*)userInfo;
@end
