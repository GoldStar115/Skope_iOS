//
//  UserDefault.m
//  UserDefaultEx
//
//  Created by CHAU HUYNH on 10/12/14.
//  Copyright (c) 2014 CHAU HUYNH. All rights reserved.
//

#import "UserDefault.h"
#import <ISDiskCache/ISDiskCache.h>


#define kUserDefault_Acc @"User_App"

@implementation UserDefault

static UserDefault *globalObject;

- (id)initWithId:(NSInteger)userID
{
    self.fb_id = [NSString stringWithFormat:@"%ld", (long)userID];
    self.commentBagedNumber = @"0";
    self.messageBagedNumber = @"0";
    self.postBagedNumber = @"0";
    self.currentDeviceToken = @"0";
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        
        self.currentDeviceToken = [aDecoder decodeObjectForKey:@"currentDeviceToken"];
        self.messageBagedNumber = [aDecoder decodeObjectForKey:@"messageBagedNumber"];
        self.postBagedNumber = [aDecoder decodeObjectForKey:@"postBagedNumber"];
        self.commentBagedNumber = [aDecoder decodeObjectForKey:@"commentBagedNumber"];
        
        self.fb_token = [aDecoder decodeObjectForKey:@"fb_token"];
        self.ln_token = [aDecoder decodeObjectForKey:@"ln_token"];
        self.original_ln_token = [aDecoder decodeObjectForKey:@"original_ln_token"];
        self.original_ln_token_expired_at = [aDecoder decodeObjectForKey:@"original_ln_token_expired_at"];
        self.email = [aDecoder decodeObjectForKey:@"email"];
        self.avatar = [aDecoder decodeObjectForKey:@"avatar"];
        self.created_date = [aDecoder decodeObjectForKey:@"created_date"];
        self.fb_id = [aDecoder decodeObjectForKey:@"fb_id"];
        self.gender = [aDecoder decodeObjectForKey:@"gender"];
        self.u_id = [aDecoder decodeObjectForKey:@"u_id"];
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.timezone = [aDecoder decodeObjectForKey:@"timezone"];
        self.isFirstTime = [aDecoder decodeObjectForKey:@"isFirstTime"];
        self.strLat = [aDecoder decodeObjectForKey:@"strLat"];
        self.strLong = [aDecoder decodeObjectForKey:@"strLong"];
        self.lastRadius = [aDecoder decodeObjectForKey:@"lastRadius"];
        
    }
    
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.currentDeviceToken forKey:@"currentDeviceToken"];
    
    [aCoder encodeObject:self.messageBagedNumber forKey:@"messageBagedNumber"];
    [aCoder encodeObject:self.postBagedNumber forKey:@"postBagedNumber"];
    [aCoder encodeObject:self.commentBagedNumber forKey:@"commentBagedNumber"];
    
    [aCoder encodeObject:self.fb_token forKey:@"fb_token"];
    [aCoder encodeObject:self.ln_token forKey:@"ln_token"];
    
    [aCoder encodeObject:self.original_ln_token forKey:@"original_ln_token"];
    [aCoder encodeObject:self.original_ln_token_expired_at forKey:@"original_ln_token_expired_at"];
    [aCoder encodeObject:self.email forKey:@"email"];
    [aCoder encodeObject:self.avatar forKey:@"avatar"];
    [aCoder encodeObject:self.created_date forKey:@"created_date"];
    [aCoder encodeObject:self.fb_id forKey:@"fb_id"];
    [aCoder encodeObject:self.gender forKey:@"gender"];
    [aCoder encodeObject:self.u_id forKey:@"u_id"];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.timezone forKey:@"timezone"];
    [aCoder encodeObject:self.isFirstTime forKey:@"isFirstTime"];
    [aCoder encodeObject:self.strLat forKey:@"strLat"];
    [aCoder encodeObject:self.strLong forKey:@"strLong"];
    [aCoder encodeObject:self.lastRadius forKey:@"lastRadius"];
}


+ (UserDefault*)currentUser {
    
    static dispatch_once_t once;
    static UserDefault *_currentUser;
    dispatch_once(&once, ^ {
        
        _currentUser = [[ISDiskCache sharedCache] objectForKey:kUserDefault_Acc];

        if (!_currentUser) {
            _currentUser = [[UserDefault alloc] init] ;
            //[UserDefault performCache];
        }

    });
    return _currentUser;
}

- (NSString*)server_access_token {
    
    return self.fb_token?self.fb_token:self.ln_token;
}


+ (void)setUser:(NSDictionary *) dicParamUser {
    
    [UserDefault currentUser].device_token = dicParamUser[@"device_token"];
    [UserDefault currentUser].email = dicParamUser[@"email"];
    [UserDefault currentUser].avatar = dicParamUser[@"avatar"];
    [UserDefault currentUser].ejabberd = dicParamUser[@"ejabberd"];
    [UserDefault currentUser].created_date = dicParamUser[@"created_at"];
    [UserDefault currentUser].fb_id = dicParamUser[@"fb_id"];
    [UserDefault currentUser].gender = dicParamUser[@"gender"];
    [UserDefault currentUser].u_id = dicParamUser[@"id"];
    [UserDefault currentUser].name = dicParamUser[@"name"];
    [UserDefault currentUser].timezone = dicParamUser[@"timezone"];
    [UserDefault currentUser].isFirstTime = dicParamUser[@"isFirstTime"];

    
    if ([dicParamUser[@"new_post_radius"] integerValue] > 1) {
        [UserDefault currentUser].lastRadius = dicParamUser[@"new_post_radius"];
    }
    
    //[UserDefault currentUser].strLat = dicParamUser[@"strLat"];
    //[UserDefault currentUser].strLong = dicParamUser[@"strLong"];
    
    [UserDefault performCache];
}

+ (void)clearInfo {
    
    [UserDefault currentUser].messageBagedNumber = @"0";
    [UserDefault currentUser].postBagedNumber = @"0";
    [UserDefault currentUser].commentBagedNumber = @"0";
    [UserDefault currentUser].currentDeviceToken = @"0";
    [UserDefault currentUser].fb_token = nil;
    [UserDefault currentUser].ln_token = nil;
    [UserDefault currentUser].original_ln_token = nil;
    [UserDefault currentUser].original_ln_token_expired_at = nil;
    [UserDefault currentUser].email = nil;
    [UserDefault currentUser].avatar = nil;
    [UserDefault currentUser].created_date = nil;
    [UserDefault currentUser].fb_id = nil;
    [UserDefault currentUser].gender = nil;
    [UserDefault currentUser].u_id = nil;
    [UserDefault currentUser].name = nil;
    [UserDefault currentUser].timezone = nil;
    [UserDefault currentUser].isFirstTime = nil;
    [UserDefault currentUser].strLat = nil;
    [UserDefault currentUser].strLong = nil;
    [UserDefault currentUser].haveNewPostNotification = @"0";
    
    [UserDefault clearCache];
}

+ (void)performCache {
    
    [[ISDiskCache sharedCache] setObject:[UserDefault currentUser] forKey:kUserDefault_Acc];
}

+ (void)clearCache {
    
    [[ISDiskCache sharedCache] removeObjectForKey:kUserDefault_Acc];
}

- (BOOL)isLoggedIn {
    
    if ((self.fb_token && self.fb_token.length) > 0 || (self.ln_token && self.ln_token.length) > 0) {
        return YES;
    }
    return NO;
}

@end
