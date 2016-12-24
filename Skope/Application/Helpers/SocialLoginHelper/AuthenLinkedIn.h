//
//  AuthenLinkedIn.h
//  Skope
//
//  Created by Netbiz on 5/29/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LIALinkedInHttpClient.h"
#import "LIALinkedInApplication.h"

typedef void(^loginLinkedInCompletion)(BOOL success, NSDictionary *accessToken, NSError *error);
typedef void(^requestMeLinkedInCompletion)(BOOL success, NSDictionary *userInfo);

@interface AuthenLinkedIn : NSObject
+ (AuthenLinkedIn*)sharedAuthenLinkedIn;
- (void)loginLinkedInWithCompletion:(loginLinkedInCompletion)completion;
- (void)requestMeWithToken:(NSString *)accessToken completion:(requestMeLinkedInCompletion)completion;
- (BOOL)validToken;
- (NSString *)accessToken;
@end
