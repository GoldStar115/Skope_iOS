//
//  PAPCache.h
//  Anypic
//
//  Created by Héctor Ramos on 5/31/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PAPCache : NSObject

+ (id)sharedCache;

- (void)clear;

- (NSDictionary *)attributesForUser:(PFUser *)user;
- (NSNumber *)photoCountForUser:(PFUser *)user;
- (BOOL)followStatusForUser:(PFUser *)user;
- (BOOL)blockStatusForUser:(PFUser *)user;

- (void)setPhotoCount:(NSNumber *)count user:(PFUser *)user;
- (void)setFollowStatus:(BOOL)following user:(PFUser *)user;
- (void)setBlockStatus:(BOOL)blocking user:(PFUser *)user;

- (void)setFacebookFriends:(NSArray *)friends;
- (NSArray *)facebookFriends;
@end
