//
//  PAPConstants.m
//  Anypic
//
//  Created by Mattieu Gamache-Asselin on 5/25/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import "PAPConstants.h"

NSString *const kPAPUserDefaultsActivityFeedViewControllerLastRefreshKey    = @"com.parse.Anypic.userDefaults.activityFeedViewController.lastRefresh";
NSString *const kPAPUserDefaultsCacheFacebookFriendsKey                     = @"com.parse.Anypic.userDefaults.cache.facebookFriends";

#pragma mark - User Info Keys
NSString *const PAPPhotoDetailsViewControllerUserLikedUnlikedPhotoNotificationUserInfoLikedKey = @"liked";
NSString *const kPAPEditPhotoViewControllerUserInfoCommentKey = @"comment";

#pragma mark - Installation Class

// Field keys
NSString *const kPAPInstallationUserKey = @"user";

// Type values
NSString *const PF_ACTIVITY_TypeLike       = @"like";
NSString *const PF_ACTIVITY_TypeFollow     = @"follow";
NSString *const PF_ACTIVITY_TypeBlock      = @"block";
NSString *const PF_ACTIVITY_TypeComment    = @"comment";
NSString *const PF_ACTIVITY_TypeJoined     = @"joined";


#pragma mark - Cached User Attributes
// keys
NSString *const kPAPUserAttributesPhotoCountKey                 = @"photoCount";
NSString *const kPAPUserAttributesIsFollowedByCurrentUserKey    = @"isFollowedByCurrentUser";
NSString *const kPAPUserAttributesIsBlockedByCurrentUserKey    = @"isBlockedByCurrentUser";


#pragma mark - Push Notification Payload Keys

NSString *const kAPNSAlertKey = @"alert";
NSString *const kAPNSBadgeKey = @"badge";
NSString *const kAPNSSoundKey = @"sound";
