//
//  PAPUtility.m
//  Anypic
//
//  Created by Mattieu Gamache-Asselin on 5/18/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import "PAPUtility.h"
#import "UIImage+ResizeAdditions.h"

@implementation PAPUtility


#pragma mark - PAPUtility
#pragma mark Like Photos

#pragma mark Facebook

+ (UIImage *)defaultProfilePicture {
    return [UIImage imageNamed:@"AvatarPlaceholderBig.png"];
}


#pragma mark Display Name

+ (NSString *)firstNameForDisplayName:(NSString *)displayName {
    if (!displayName || displayName.length == 0) {
        return @"Someone";
    }
    
    NSArray *displayNameComponents = [displayName componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *firstName = [displayNameComponents objectAtIndex:0];
    if (firstName.length > 100) {
        // truncate to 100 so that it fits in a Push payload
        firstName = [firstName substringToIndex:100];
    }
    return firstName;
}


#pragma mark User Following

+ (void)followUserInBackground:(PFUser *)user block:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    if ([[user objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        return;
    }
    
    PFObject *followActivity = [PFObject objectWithClassName:PF_ACTIVITY_CLASS_NAME];
    [followActivity setObject:[PFUser currentUser] forKey:PF_ACTIVITY_FROMUSERKEY];
    [followActivity setObject:user forKey:PF_ACTIVITY_TOUSERKEY];
    [followActivity setObject:PF_ACTIVITY_TypeFollow forKey:PF_ACTIVITY_TYPEKEY];
    
    PFACL *followACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [followACL setPublicReadAccess:YES];
    followActivity.ACL = followACL;
    
    [followActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (completionBlock) {
            completionBlock(succeeded, error);
        }
    }];
    [[PAPCache sharedCache] setFollowStatus:YES user:user];
}

+ (void)followUserEventually:(PFUser *)user block:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    if ([[user objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        return;
    }
    
    PFObject *followActivity = [PFObject objectWithClassName:PF_ACTIVITY_CLASS_NAME];
    [followActivity setObject:[PFUser currentUser] forKey:PF_ACTIVITY_FROMUSERKEY];
    [followActivity setObject:user forKey:PF_ACTIVITY_TOUSERKEY];
    [followActivity setObject:PF_ACTIVITY_TypeFollow forKey:PF_ACTIVITY_TYPEKEY];
    
    PFACL *followACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [followACL setPublicReadAccess:YES];
    followActivity.ACL = followACL;
    
    [followActivity saveEventually:completionBlock];
    [[PAPCache sharedCache] setFollowStatus:YES user:user];
}

+ (void)followUsersEventually:(NSArray *)users block:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    for (PFUser *user in users) {
        [PAPUtility followUserEventually:user block:completionBlock];
        [[PAPCache sharedCache] setFollowStatus:YES user:user];
    }
}


+ (void)blockUserEventually:(PFUser *)user block:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    if ([[user objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        return;
    }
    
    PFObject *blockActivity = [PFObject objectWithClassName:PF_ACTIVITY_CLASS_NAME];
    [blockActivity setObject:[PFUser currentUser] forKey:PF_ACTIVITY_FROMUSERKEY];
    [blockActivity setObject:user forKey:PF_ACTIVITY_TOUSERKEY];
    [blockActivity setObject:PF_ACTIVITY_TypeBlock forKey:PF_ACTIVITY_TYPEKEY];
    
    PFACL *blockACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [blockACL setPublicReadAccess:YES];
    blockActivity.ACL = blockACL;
    
    [blockActivity saveEventually:completionBlock];
    [[PAPCache sharedCache] setBlockStatus:YES user:user];
}

+ (void)unfollowUserEventually:(PFUser *)user {
    PFQuery *query = [PFQuery queryWithClassName:PF_ACTIVITY_CLASS_NAME];
    [query whereKey:PF_ACTIVITY_FROMUSERKEY equalTo:[PFUser currentUser]];
    [query whereKey:PF_ACTIVITY_TOUSERKEY equalTo:user];
    [query whereKey:PF_ACTIVITY_TYPEKEY equalTo:PF_ACTIVITY_TypeFollow];
    [query findObjectsInBackgroundWithBlock:^(NSArray *followActivities, NSError *error) {
        // While normally there should only be one follow activity returned, we can't guarantee that.
        
        if (!error) {
            for (PFObject *followActivity in followActivities) {
                [followActivity deleteEventually];
            }
        }
    }];
    [[PAPCache sharedCache] setFollowStatus:NO user:user];
}

+ (void)unfollowUsersEventually:(NSArray *)users {
    PFQuery *query = [PFQuery queryWithClassName:PF_ACTIVITY_CLASS_NAME];
    [query whereKey:PF_ACTIVITY_FROMUSERKEY equalTo:[PFUser currentUser]];
    [query whereKey:PF_ACTIVITY_TOUSERKEY containedIn:users];
    [query whereKey:PF_ACTIVITY_TYPEKEY equalTo:PF_ACTIVITY_TypeFollow];
    [query findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
        for (PFObject *activity in activities) {
            [activity deleteEventually];
        }
    }];
    for (PFUser *user in users) {
        [[PAPCache sharedCache] setFollowStatus:NO user:user];
    }
}


#pragma mark Activities

+ (PFQuery *)queryForActivitiesOnUser:(PFUser *)user cachePolicy:(PFCachePolicy)cachePolicy {
    PFQuery *query_Users_were_blocked_by_this_user = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
    [query_Users_were_blocked_by_this_user whereKey:PF_ACTIVITY_FROMUSERKEY equalTo:user];
    [query_Users_were_blocked_by_this_user whereKey:PF_ACTIVITY_TYPEKEY equalTo:PF_ACTIVITY_TypeBlock];
    
    PFQuery *query_Users_blocked_this_user = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
    [query_Users_blocked_this_user whereKey:PF_ACTIVITY_TOUSERKEY equalTo:user];
    [query_Users_blocked_this_user whereKey:PF_ACTIVITY_TYPEKEY equalTo:PF_ACTIVITY_TypeBlock];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:query_Users_were_blocked_by_this_user,query_Users_blocked_this_user,nil]];
    [query setCachePolicy:cachePolicy];
    [query includeKey:PF_ACTIVITY_FROMUSERKEY];
    [query includeKey:PF_ACTIVITY_TOUSERKEY];
    
    return query;
}


#pragma mark Shadow Rendering

+ (void)drawSideAndBottomDropShadowForRect:(CGRect)rect inContext:(CGContextRef)context {
    // Push the context 
    CGContextSaveGState(context);
    
    // Set the clipping path to remove the rect drawn by drawing the shadow
    CGRect boundingRect = CGContextGetClipBoundingBox(context);
    CGContextAddRect(context, boundingRect);
    CGContextAddRect(context, rect);
    CGContextEOClip(context);
    // Also clip the top and bottom
    CGContextClipToRect(context, CGRectMake(rect.origin.x - 10.0f, rect.origin.y, rect.size.width + 20.0f, rect.size.height + 10.0f));
    
    // Draw shadow
    [[UIColor blackColor] setFill];
    CGContextSetShadow(context, CGSizeMake(0.0f, 0.0f), 7.0f);
    CGContextFillRect(context, CGRectMake(rect.origin.x, 
                                          rect.origin.y - 5.0f, 
                                          rect.size.width, 
                                          rect.size.height + 5.0f));
    // Save context
    CGContextRestoreGState(context);
}

+ (void)drawSideAndTopDropShadowForRect:(CGRect)rect inContext:(CGContextRef)context {
    // Push the context 
    CGContextSaveGState(context);
    
    // Set the clipping path to remove the rect drawn by drawing the shadow
    CGRect boundingRect = CGContextGetClipBoundingBox(context);
    CGContextAddRect(context, boundingRect);
    CGContextAddRect(context, rect);
    CGContextEOClip(context);
    // Also clip the top and bottom
    CGContextClipToRect(context, CGRectMake(rect.origin.x - 10.0f, rect.origin.y - 10.0f, rect.size.width + 20.0f, rect.size.height + 10.0f));
    
    // Draw shadow
    [[UIColor blackColor] setFill];
    CGContextSetShadow(context, CGSizeMake(0.0f, 0.0f), 7.0f);
    CGContextFillRect(context, CGRectMake(rect.origin.x, 
                                          rect.origin.y, 
                                          rect.size.width, 
                                          rect.size.height + 10.0f));
    // Save context
    CGContextRestoreGState(context);
}

+ (void)drawSideDropShadowForRect:(CGRect)rect inContext:(CGContextRef)context {    
    // Push the context 
    CGContextSaveGState(context);
    
    // Set the clipping path to remove the rect drawn by drawing the shadow
    CGRect boundingRect = CGContextGetClipBoundingBox(context);
    CGContextAddRect(context, boundingRect);
    CGContextAddRect(context, rect);
    CGContextEOClip(context);
    // Also clip the top and bottom
    CGContextClipToRect(context, CGRectMake(rect.origin.x - 10.0f, rect.origin.y, rect.size.width + 20.0f, rect.size.height));
    
    // Draw shadow
    [[UIColor blackColor] setFill];
    CGContextSetShadow(context, CGSizeMake(0.0f, 0.0f), 7.0f);
    CGContextFillRect(context, CGRectMake(rect.origin.x, 
                                          rect.origin.y - 5.0f, 
                                          rect.size.width, 
                                          rect.size.height + 10.0f));
    // Save context
    CGContextRestoreGState(context);
}
@end
