//
//  AuthenLinkedIn.m
//  Skope
//
//  Created by Netbiz on 5/29/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import "AuthenLinkedIn.h"

@interface AuthenLinkedIn ()
@property (nonatomic, strong) LIALinkedInHttpClient * client;
@end

@implementation AuthenLinkedIn

- (instancetype)init {
    self = [super init];
    if (self) {
        self.client = [self LinkedInclient];
    }
    return self;
}

+ (AuthenLinkedIn*)sharedAuthenLinkedIn {
    static AuthenLinkedIn *_sharedAuthenLinkedIn = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedAuthenLinkedIn = [[AuthenLinkedIn alloc] init];
    });
    
    return _sharedAuthenLinkedIn;
}


- (void)requestMeWithToken:(NSString *)accessToken completion:(requestMeLinkedInCompletion)completion {

    [self.client GET:[NSString stringWithFormat:@"https://api.linkedin.com/v1/people/~:(id,first-name,last-name,headline,maiden-name,email-address,picture-urls::(original))?oauth2_access_token=%@&format=json", accessToken] parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *result) {
        
        completion(YES,result);
        
        //NSLog(@"current linkedin user %@", result);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        completion(NO,nil);
        
        //NSLog(@"failed to fetch current user %@", error);
    }];
}

- (void)loginLinkedInWithCompletion:(loginLinkedInCompletion)completion {
    
    __weak __typeof(self)weakSelf = self;
    typeof(self) selfBlock = weakSelf;
    
    [self.client getAuthorizationCode:^(NSString *code) {
        
        [selfBlock.client getAccessToken:code success:^(NSDictionary *accessTokenData) {
            
            //NSLog(@"Access token data: %@",accessTokenData);
            
            completion (YES, accessTokenData, nil);
            
        }                   failure:^(NSError *error) {
            completion (NO, nil, error);
            //NSLog(@"Quering accessToken failed %@", error);
        }];
    }                      cancel:^{
        //NSLog(@"Authorization was cancelled by user");
        completion (NO, nil, nil);
    }                     failure:^(NSError *error) {
        //NSLog(@"Authorization failed %@", error);
        completion (NO, nil, error);
    }];
}

- (BOOL)validToken {
    return [[self client] validToken];
}

- (NSString *)accessToken {
    return [[self client] accessToken];
}

- (LIALinkedInHttpClient *)LinkedInclient {
    LIALinkedInApplication *application = [LIALinkedInApplication applicationWithRedirectURL:LINKEDIN_REDIRECT_URI
                                                                                    clientId:LINKEDIN_CLIENT_ID
                                                                                clientSecret:LINKEDIN_CLIENT_SECRET
                                                                                       state:@"DCEEFWF45453sdffef424"
                                                                               grantedAccess:@[@"r_basicprofile", @"r_emailaddress"]];
    return [LIALinkedInHttpClient clientForApplication:application presentingViewController:nil];
}

@end
