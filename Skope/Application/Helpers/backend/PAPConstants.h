//
//  PAPConstants.h
//  Anypic
//
//  Created by Mattieu Gamache-Asselin on 5/25/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

typedef enum {
	PAPHomeTabBarItemIndex = 0,
	PAPEmptyTabBarItemIndex = 1,
	PAPActivityTabBarItemIndex = 2
} PAPTabBarControllerViewControllerIndex;


// Ilya     400680
// James    403902
// David    1225726
// Bryan    4806789
// Thomas   6409809
// Ashley   12800553
// Héctor   121800083
// Kevin    500011038
// Chris    558159381
// Matt     723748661

#define kPAPParseEmployeeAccounts [NSArray arrayWithObjects:@"400680", @"403902", @"1225726", @"4806789", @"6409809", @"12800553", @"121800083", @"500011038", @"558159381", @"723748661", nil]

#pragma mark - NSUserDefaults
extern NSString *const kPAPUserDefaultsActivityFeedViewControllerLastRefreshKey;
extern NSString *const kPAPUserDefaultsCacheFacebookFriendsKey;

#pragma mark - User Info Keys
extern NSString *const PAPPhotoDetailsViewControllerUserLikedUnlikedPhotoNotificationUserInfoLikedKey;
extern NSString *const kPAPEditPhotoViewControllerUserInfoCommentKey;


#pragma mark - Installation Class

// Field keys
extern NSString *const kPAPInstallationUserKey;

// Type values
extern NSString *const PF_ACTIVITY_TypeLike;
extern NSString *const PF_ACTIVITY_TypeFollow;
extern NSString *const PF_ACTIVITY_TypeBlock;
extern NSString *const PF_ACTIVITY_TypeComment;
extern NSString *const PF_ACTIVITY_TypeJoined;


#pragma mark - Cached User Attributes
// keys
extern NSString *const kPAPUserAttributesPhotoCountKey;
extern NSString *const kPAPUserAttributesIsFollowedByCurrentUserKey;
extern NSString *const kPAPUserAttributesIsBlockedByCurrentUserKey;
