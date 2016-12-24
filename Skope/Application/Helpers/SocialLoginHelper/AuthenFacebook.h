//
//  AuthenFacebook.h
//  Vidality
//
//  Created by CHAU HUYNH on 10/14/14.
//  Copyright (c) 2014 CHAU HUYNH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
//#import <FBSDKShareKit/FBSDKShareKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

typedef void(^loginFacebookCompletion)(FBSDKLoginManagerLoginResult *result, NSError *error);

@interface AuthenFacebook : NSObject
+ (AuthenFacebook *) sharedAuthenFacebook;
- (void) clearAllDataAndLogoutAllAccount;
+ (NSString *) accessTokenFB;
- (void) beginAuthenFBWithCompletion:(loginFacebookCompletion)completion fromViewController:(UIViewController*)viewController;
@end
