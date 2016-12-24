//
//  UserDefault.h
//  UserDefaultEx
//
//  Created by CHAU HUYNH on 10/12/14.
//  Copyright (c) 2014 CHAU HUYNH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AuthenFacebook.h"
#import "AuthenLinkedIn.h"

@interface UserDefault : NSObject<NSCoding>

@property(nonatomic,strong) NSString* currentDeviceToken;

@property(nonatomic,strong) NSString* postBagedNumber;
@property(nonatomic,strong) NSString* messageBagedNumber;
@property(nonatomic,strong) NSString* commentBagedNumber;
@property(nonatomic,strong) NSString* device_token;

@property(nonatomic,strong) NSString *fb_token;
@property(nonatomic,strong) NSString *ln_token;
@property(nonatomic,strong) NSString *original_ln_token_expired_at;
@property(nonatomic,strong) NSString *original_ln_token;

@property(nonatomic,strong) NSString *email;
@property(nonatomic,strong) NSDictionary *ejabberd;
@property(nonatomic,strong) NSString *avatar;
@property(nonatomic,strong) NSString *created_date;
@property(nonatomic,strong) NSString *fb_id;
@property(nonatomic,strong) NSString *lk_id;
@property(nonatomic,strong) NSString *gender;
@property(nonatomic,strong) NSString *u_id;
@property(nonatomic,strong) NSString *name;
@property(nonatomic,strong) NSString *timezone;
@property(nonatomic,strong) NSString *isFirstTime;
@property(nonatomic,strong) NSString *strLong;
@property(nonatomic,strong) NSString *strLat;
@property(nonatomic,strong) NSString *lastRadius;

@property(nonatomic,strong) NSString *haveNewPostNotification;

+ (UserDefault*)currentUser;

+ (void)setUser:(NSDictionary *) dicParamUser;
+ (void)performCache;
+ (void)clearInfo;

- (NSString*)server_access_token;
- (BOOL)isLoggedIn;
@end
