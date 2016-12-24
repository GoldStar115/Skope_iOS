//
//  AuthenFacebook.m
//  Vidality
//
//  Created by CHAU HUYNH on 10/14/14.
//  Copyright (c) 2014 CHAU HUYNH. All rights reserved.
//

#import "AuthenFacebook.h"

@interface AuthenFacebook ()

@end

@implementation AuthenFacebook

+ (AuthenFacebook *) sharedAuthenFacebook
{
    static AuthenFacebook *_sharedAuthenFacebook = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedAuthenFacebook = [[AuthenFacebook alloc] init];
    });
    return _sharedAuthenFacebook;
}

- (void) beginAuthenFBWithCompletion:(loginFacebookCompletion)completion  fromViewController:(UIViewController*)viewController{

    FBSDKLoginManager *loginManager = [PFFacebookUtils facebookLoginManager];

//    [loginManager logInWithPublishPermissions:@[@"public_profile", @"email"/*, @"user_friends"*/] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
//        completion(result, error);
//    }];
    
//    [loginManager logInWithReadPermissions:@[@"public_profile", @"email"/*, @"user_friends"*/] fromViewController:nil handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
//        completion(result, error);
//    }];

    [loginManager logInWithReadPermissions:@[@"public_profile", @"email"/*, @"user_friends"*/] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        completion(result, error);
    }];
    
}

- (void) clearAllDataAndLogoutAllAccount {
    
    [[PFFacebookUtils facebookLoginManager] logOut];
    [UserDefault clearInfo];
    [[ISDiskCache sharedCache] removeOldObjects];
    [PFUser logOut];
}

+ (NSString *) accessTokenFB {
    return [[FBSDKAccessToken currentAccessToken] tokenString];
}

@end
