//
//  LoginFBVC.m
//  Skope
//
//  Created by Huynh Phong Chau on 2/28/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import "LoginFBVC.h"
#include "Define.h"
#import <ISDiskCache/ISDiskCache.h>
#import "UIImage+Resizing.h"
#import "pushnotification.h"

#import "MainViewController.h"

#define FACEBOOK_GRAPH_API_FOR_ME_2_4           @"/me/?fields=id,first_name,last_name,name,birthday,email,picture,gender,location,hometown"
// @"/me/?fields=id,first_name,last_name,name,birthday,email,picture,gender,location,address,hometown"

typedef void(^ParseLoginWithLKUserInfoCompletion)(PFUser *user, NSError *error);
typedef void(^MainServerLoginWithLKUserInfoSuccessCompletion)(AFHTTPRequestOperation *operation, id responseObject);
typedef void(^UpdateParseUserInfoFromFaceBookCompletion)(BOOL succeeded, NSError *error);
typedef void(^UpdateParseUserInfoFromLinkedInCompletion)(BOOL succeeded, NSError *error);

@interface LoginFBVC () <TTTAttributedLabelDelegate>

@property (nonatomic, strong) TTTAttributedLabel *summaryLabel;

@property (nonatomic, strong) UIDynamicAnimator *animator;

@property (weak, nonatomic) IBOutlet UIImageView *imgV_app_logo;
@property (weak, nonatomic) IBOutlet UILabel *lbl_app_slogan;

@property (weak, nonatomic) IBOutlet UIButton *btn_login_FB;
@property (weak, nonatomic) IBOutlet UIButton *btn_login_LK;

- (IBAction)actionLoginFB:(id)sender;
- (IBAction)actionLoginLK:(id)sender;

@end

@implementation LoginFBVC

- (void)viewDidLoad {
    
    [super viewDidLoad];

    [self createAttributeLableForTermsAndPolicy];
    
    //Open facebook session
    
    // Set up our Animation
    
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    [self.lbl_app_slogan setAttributedText:[[NSAttributedString alloc] initWithString:@"The simplest way\nto connect with the world\naround you " attributes:@{[UIFont fontWithName:@"OpenSans-Light" size:26.0]:NSFontAttributeName,paragraphStyle:NSParagraphStyleAttributeName}]];
    
    [self.lbl_containerView setCenter:CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds) - 10)];
    
    [self.btn_containerView setCenter:CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMinY(self.view.bounds) - 100)];
    
    [self enableLoginButtons];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
//    UIImageView* newImage = [UIImage imageNamed:@"btPlayVideo.png"];
//    CATransition *animation = [CATransition animation];
//    [animation setDuration:0.25];
//    [animation setType:kCATransitionPush];
//    [animation setSubtype:kCATransitionFromRight];
//    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
//    [[self.background_imageView layer] addAnimation:animation forKey:@"SwitchToView1"];
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationDuration:0.75];
//    self.background_imageView.image = newImage;
//    [UIView commitAnimations];
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - AUTHEN FACEBOOK DELEGATE

- (void)loginParseWithFaceBookAccesstoken:(FBSDKAccessToken*)accesstoken {
    
    [PFUser logOut];
    
    __weak __typeof(self)weakSelf = self;
    typeof(self) selfBlock = weakSelf;
    
    NSString *validTokenString = accesstoken.tokenString;
    
    NSLog(@"logInInBackgroundWithAccessToken Token String: %@",validTokenString);
    
    [PFFacebookUtils logInInBackgroundWithAccessToken:accesstoken block:^(PFUser *PF_NULLABLE_S user, NSError *PF_NULLABLE_S error) {
        
        NSLog(@"logInInBackgroundWithAccessToken Token String: %@",[FBSDKAccessToken currentAccessToken].tokenString);
        
        if (user) {
            
            if (user.isNew || user[PF_USER_FACEBOOKID] == nil) {
                
                // User no register for this app before => get more info and send to server
                
                [selfBlock requestMoreFacebookInfoAndUpdateToParseForParseUser:user];
                
            } else {
                
                [selfBlock userLoggedIn:user token:validTokenString isFBToken:YES];
                
            }
            
        } else {
            
            [Common hideLoadingViewGlobal];
            
            [[AuthenFacebook sharedAuthenFacebook] clearAllDataAndLogoutAllAccount];
            
            [selfBlock enableLoginButtons];
            
            if (!error) {
                
                //NSLog(@"The user cancelled the Facebook login.");
                
                [Common showAlertView:APP_NAME message:MSS_NEED_LOGIN delegate:nil cancelButtonTitle:ALERTVIEW_OK_BUTTON arrayTitleOtherButtons:nil tag:0];
                
            } else {
                
                //[selfBlock handleRequestPermissionInfoAPICallError:error];
                
                NSLog(@"FBSDKGraphRequestErrorHTTPStatusCodeKey: %@",[[error userInfo] objectForKey:@"com.facebook.sdk:FBSDKGraphRequestErrorHTTPStatusCodeKey"]);
                NSLog(@"FBSDKGraphRequestErrorErrorSubcode: %@",[[error userInfo] objectForKey:@"com.facebook.sdk:FBSDKGraphRequestErrorErrorSubcode"]);
                NSLog(@"FBSDKGraphRequestErrorErrorCode: %@",[[error userInfo] objectForKey:@"com.facebook.sdk:FBSDKGraphRequestErrorErrorCode"]);
                NSLog(@"FBSDKGraphRequestErrorCategoryKey: %@",[[error userInfo] objectForKey:@"com.facebook.sdk:FBSDKGraphRequestErrorCategoryKey"]);
                NSLog(@"FBSDKErrorLocalizedTitleKey: %@",[[error userInfo] objectForKey:@"com.facebook.sdk:FBSDKErrorLocalizedTitleKey"]);
                NSLog(@"FBSDKErrorLocalizedDescriptionKey: %@",[[error userInfo] objectForKey:@"com.facebook.sdk:FBSDKErrorLocalizedDescriptionKey"]);
                NSLog(@"End Error");

                [Common showAlertView:HAVE_AN_ERROR message:MSS_TRY_AGAIN delegate:selfBlock cancelButtonTitle:ALERTVIEW_OK_BUTTON arrayTitleOtherButtons:nil tag:0];
            }
        }
    }];
}

- (void)loginParseWithLKUserInfo:(NSDictionary*)lk_userInfo completion:(ParseLoginWithLKUserInfoCompletion)completion{
    
    [PFUser logOut];
    
    __block NSString* username = lk_userInfo[@"ejabberd"][@"username"];
    __block NSString* password = PARSE_DEFAULT_PASSWORD;
    __block NSString* emailcopy = lk_userInfo[@"email"];
    
    // find account with email exist or not
    
    PFQuery *query = [PFUser query];
    
    [query whereKey:@"emailCopy" equalTo:emailcopy];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *PF_NULLABLE_S object,  NSError *PF_NULLABLE_S error){
        
        PFUser *exitUser = (PFUser *)object;
        
        if (!exitUser) {
            
            //NSLog(@"Email is not exit => Create new user by LinkedIn");
            
            __block PFUser *newUser = [[PFUser alloc] init];
            newUser.username = username;
            newUser.password = password;
            [newUser setObject:emailcopy forKey:PF_USER_EMAILCOPY];
            
            [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                if(!error) {
                    
                    completion (newUser, error);
                    
                } else {
                    
                    //NSLog(@"Error code: %@", error.userInfo[@"code"]);
                    
                    //NSLog(@"Error description: %@", error.userInfo[@"error"]);
                    
                    if (error.code == 202) {
                        
                        // username or email already taken ==> try to login
                        
                        [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error){
                            completion (user, error);
                        }];
                        
                    } else {
                        
                        completion (nil, error);
                    }
                }
            }];
        }
        else
        {
            //NSLog(@"Email is exit => User Loged In with Facebook Before");
            
            [PFUser logInWithUsernameInBackground:exitUser.username password:password block:^(PFUser *user, NSError *error){
                completion (user, error);
            }];
        }
    }];
    
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


- (void) requestMoreFacebookInfoAndUpdateToParseForParseUser:(PFUser *)pf_user
{
    __weak __typeof(self)weakSelf = self;
    typeof(self) selfBlock = weakSelf;
    
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:FACEBOOK_GRAPH_API_FOR_ME_2_4
                                                                   parameters:nil];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        
        // Handle results or error of request.
        
        if (error == nil)
        {
            if (![[FBSDKAccessToken currentAccessToken] hasGranted:@"email"]) {
                
                [Common showAlertView:APP_NAME message:@"Skope need your email address!" delegate:selfBlock cancelButtonTitle:ALERTVIEW_OK_BUTTON arrayTitleOtherButtons:@[@"Not now"] tag:88];
                
            } else {
                
                NSDictionary *fb_UserInfo = (NSDictionary *)result;
                
                [selfBlock updateFaceBookUserInfoToParseForPFUser:pf_user withFBUserInfo:fb_UserInfo completion:^(BOOL succeeded, NSError *error) {
                    
                    [Common hideLoadingViewGlobal];
                    
                    if (error == nil)
                    {
                        [selfBlock userLoggedIn:[PFUser currentUser] token:[AuthenFacebook accessTokenFB] isFBToken:YES];
                    }
                    else
                    {
                        [[AuthenFacebook sharedAuthenFacebook] clearAllDataAndLogoutAllAccount];
                    }
                    
                }];
            }
        }
        else
        {
            [[AuthenFacebook sharedAuthenFacebook] clearAllDataAndLogoutAllAccount];
            //[self handleRequestPermissionInfoAPICallError:error];
            //NSLog(@"Failed to fetch Facebook user data.");
        }
    }];
    
}

- (void)updateFaceBookUserInfoToParseForPFUser:(PFUser *)user withFBUserInfo:(NSDictionary *)fb_UserInfo completion:(UpdateParseUserInfoFromFaceBookCompletion)completion
{    
    [Common showLoadingViewGlobal:nil];
    
    NSString *picture_link = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", fb_UserInfo[@"id"]];
    
    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:picture_link] options:SDWebImageDownloaderContinueInBackground progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
        
        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
            if (image) {
                
                UIImage *picture = image;//[[image scaleToAspectFillSize:CGSizeMake(280.0, 280.0)] cropToSize:CGSizeMake(280.0, 280.0) usingMode:XNYCropModeCenter];//ResizeImage(image, 280, 280);
                UIImage *thumbnail = [picture scaleToAspectFillSize:CGSizeMake(140.0, 140.0)];//ResizeImage(image, 60, 60);
                
                PFFile *filePicture = [PFFile fileWithName:@"picture.jpg" data:UIImageJPEGRepresentation(picture,kImageEncodeQualityForUpload)];
                [filePicture saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                 {
                     if (error != nil) {
                         //NSLog(@"Network error.");
                     }
                 }];
                
                PFFile *fileThumbnail = [PFFile fileWithName:@"thumbnail.jpg" data:UIImageJPEGRepresentation(thumbnail,kImageEncodeQualityForUpload)];
                [fileThumbnail saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                 {
                     if (error != nil) {
                         //NSLog(@"Network error.");
                     }
                 }];
                
                user[PF_USER_PICTURE] = filePicture;
                user[PF_USER_THUMBNAIL] = fileThumbnail;
            }
            
            if (fb_UserInfo[@"email"]) {
                user[PF_USER_EMAILCOPY] = fb_UserInfo[@"email"];
            }
            if (fb_UserInfo[@"name"]) {
                NSString *hiddenName = [Common hiddenName:fb_UserInfo[@"name"]];
                user[PF_USER_FULLNAME] = hiddenName;
                user[PF_USER_FULLNAME_LOWER] = [hiddenName lowercaseString];
            }
            if (fb_UserInfo[@"id"]) {
                user[PF_USER_FACEBOOKID] = fb_UserInfo[@"id"];
            }
            
            user[PF_USER_PASSWORD] = PARSE_DEFAULT_PASSWORD;
            
            [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                runOnMainQueueWithoutDeadlocking(^{
                    completion (succeeded, error);
                });
            }];
        
        });
    }];
}


- (void)updateLinkedInUserInfoToParseForPFUser:(PFUser *)user withLKUserInfoFromMainServer:(NSDictionary *)LK_userInfo_from_main_server completion:(UpdateParseUserInfoFromLinkedInCompletion)completion
{
    [Common showLoadingViewGlobal:nil];
    
    NSString *picture_link = LK_userInfo_from_main_server[@"avatar"];
    
    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:picture_link] options:SDWebImageDownloaderContinueInBackground progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
        
        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{

            if (image) {
                
                UIImage *picture = image;//[[image scaleToAspectFillSize:CGSizeMake(280.0, 280.0)] cropToSize:CGSizeMake(280.0, 280.0) usingMode:XNYCropModeCenter];//ResizeImage(image, 280, 280);
                UIImage *thumbnail = [picture scaleToAspectFillSize:CGSizeMake(140.0, 140.0)];//ResizeImage(image, 60, 60);
                
                PFFile *filePicture = [PFFile fileWithName:@"picture.jpg" data:UIImageJPEGRepresentation(picture,kImageEncodeQualityForUpload)];
                [filePicture saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                 {
                     if (error != nil) {
                         //NSLog(@"Network error.");
                     }
                 }];
                
                PFFile *fileThumbnail = [PFFile fileWithName:@"thumbnail.jpg" data:UIImageJPEGRepresentation(thumbnail,kImageEncodeQualityForUpload)];
                [fileThumbnail saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                 {
                     if (error != nil) {
                         //NSLog(@"Network error.");
                     }
                 }];
                
                user[PF_USER_PICTURE] = filePicture;
                user[PF_USER_THUMBNAIL] = fileThumbnail;
            }
            
            if (LK_userInfo_from_main_server[@"emailAddress"]) {
                user[PF_USER_EMAILCOPY] = LK_userInfo_from_main_server[@"emailAddress"];
            }
            
            if (![user objectForKey:PF_USER_FULLNAME] || ((NSString*)[user objectForKey:PF_USER_FULLNAME]).length == 0) {
                
                if (LK_userInfo_from_main_server[@"first_name"] || LK_userInfo_from_main_server[@"last_name"]) {
                    
                    NSString *firstName = LK_userInfo_from_main_server[@"first_name"]?[NSString stringWithFormat:@"%@ ",LK_userInfo_from_main_server[@"first_name"]]:@"";
                    NSString *lastName = LK_userInfo_from_main_server[@"last_name"]?[NSString stringWithFormat:@"%@",LK_userInfo_from_main_server[@"last_name"]]:@"";
                    NSString *fullName = [NSString stringWithFormat:@"%@ %@",firstName,lastName];
                    
                    NSString *hiddenName = [Common hiddenName:fullName];
                    user[PF_USER_FULLNAME] = hiddenName;
                    user[PF_USER_FULLNAME_LOWER] = [hiddenName lowercaseString];
                }
                
            } else {
                
                NSString *hiddenName = [Common hiddenName:LK_userInfo_from_main_server[@"name"]];
                user[PF_USER_FULLNAME] = hiddenName;
                user[PF_USER_FULLNAME_LOWER] = [hiddenName lowercaseString];
            }
            
            [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                runOnMainQueueWithoutDeadlocking(^{
                    completion (succeeded, error);
                });
                
            }];
            
        });
    }];
}


- (void)userLoggedIn:(PFUser *)user token:(NSString*)token isFBToken:(BOOL)isFBToken
{
    
    ParsePushUserAssign();
    NSLog(@"Welcome back %@!", user[PF_USER_FULLNAME]);
    
    if (isFBToken) {
        
        // Need to login main if user login with facebook account
        
        [self loginToMainServerWithFaceBookToken:token];
    }
    else {
        //NSLog(@"  NOT GO TO loginToMainServerWithFaceBookToken");
    }
}

- (void) loginToMainServerWithFaceBookToken:(NSString *)tokenString{
    
    [Common showLoadingViewGlobal:nil];
    
    AFHTTPRequestOperationManager *manager = [Common AFHTTPRequestOperationManagerReturn];
    
    NSString *device_token = [[ISDiskCache sharedCache] objectForKey:APP_DEVICE_TOKEN];
    
    NSMutableDictionary *request_param = [[NSMutableDictionary alloc] init];
    
    [request_param setObject:tokenString forKey:@"fb_token"];
    
    if (device_token && device_token.length > 0) {
        
        [request_param setObject:device_token forKey:@"ios_device_token"];
        
    }
    
    __weak __typeof(self)weakSelf = self;
    typeof(self) selfBlock = weakSelf;
    
    NSLog(@"loginToMainServerWithFaceBookToken Token String: %@",[FBSDKAccessToken currentAccessToken].tokenString);
    
    [manager POST:URL_SERVER_API(API_USER_LOGIN) parameters:request_param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [Common hideLoadingViewGlobal];
        
        if ([Common validateResponse:responseObject]) {
            
            // Save user info and goto mainVC
            
            NSDictionary *data = responseObject[@"data"];
            NSDictionary *accessTokenServer = data[@"accessToken"];
            NSDictionary *user = data[@"user"];
            
            if (accessTokenServer[@"token"]) {
                
                [[UserDefault currentUser] setFb_token:accessTokenServer[@"token"]];
                [[UserDefault currentUser] setLn_token:nil];
                
            }
            
            if (user) {
                
                [UserDefault setUser:user];
                [AppDelegate sendDeviceTokenToServer:[[ISDiskCache sharedCache] objectForKey:APP_DEVICE_TOKEN]];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_USER_LOGGED_IN object:nil userInfo:nil];
                

                
            }
            
        } else {
            
            [selfBlock enableLoginButtons];
            
            [[AuthenFacebook sharedAuthenFacebook] clearAllDataAndLogoutAllAccount];
            
            NSString *errorMsg = [Common errorMessageFromResponseObject:responseObject];
            
            [Common showAlertView:APP_NAME message:errorMsg?errorMsg:MSS_LOGIN_TRY_AGAIN delegate:selfBlock cancelButtonTitle:ALERTVIEW_OK_BUTTON arrayTitleOtherButtons:nil tag:0];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [Common hideLoadingViewGlobal];
        
        [[AuthenFacebook sharedAuthenFacebook] clearAllDataAndLogoutAllAccount];
        
        [selfBlock enableLoginButtons];
        
        [Common showAlertView:APP_NAME message:MSS_LOGIN_TRY_AGAIN delegate:selfBlock cancelButtonTitle:ALERTVIEW_OK_BUTTON arrayTitleOtherButtons:nil tag:0];
    }];
    
}

- (void) loginToMainServerWithLKToken:(NSString *)tokenString completion:(MainServerLoginWithLKUserInfoSuccessCompletion)completion {
    
    [Common showLoadingViewGlobal:nil];
    
    AFHTTPRequestOperationManager *manager = [Common AFHTTPRequestOperationManagerReturn];
    
    NSString *device_token = [[ISDiskCache sharedCache] objectForKey:APP_DEVICE_TOKEN];
    
    NSMutableDictionary *request_param = [[NSMutableDictionary alloc] init];
    
    [request_param setObject:tokenString forKey:@"ln_token"];
    
    if (device_token && device_token.length > 0) {
        
        [request_param setObject:device_token forKey:@"ios_device_token"];
        
    }
    
    __weak __typeof(self)weakSelf = self;
    typeof(self) selfBlock = weakSelf;
    
    [manager POST:URL_SERVER_API(API_USER_LOGIN) parameters:request_param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        completion (operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [Common hideLoadingViewGlobal];
        
        [[AuthenFacebook sharedAuthenFacebook] clearAllDataAndLogoutAllAccount];
        
        [selfBlock enableLoginButtons];
        
        [Common showAlertView:APP_NAME message:MSS_LOGIN_TRY_AGAIN delegate:selfBlock cancelButtonTitle:ALERTVIEW_OK_BUTTON arrayTitleOtherButtons:nil tag:0];
    }];
    
}

#pragma mark - UIAlerViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == 88) {
        
        if (buttonIndex == 0) {
            
            __weak __typeof(self)weakSelf = self;
            typeof(self) selfBlock = weakSelf;
            
            FBSDKLoginManager *loginManager = [PFFacebookUtils facebookLoginManager];
            //loginManager.loginBehavior = FBSDKLoginBehaviorSystemAccount;
            
            [loginManager logInWithReadPermissions:@[@"public_profile", @"email"/*, @"user_friends"*/] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                if (!error) {
                    if ([[FBSDKAccessToken currentAccessToken] hasGranted:@"email"]) {
                        if ([PFUser currentUser].isNew || [PFUser currentUser][PF_USER_FACEBOOKID] == nil) {
                            
                            //User no register for this app before => get more info and send to server
                            [selfBlock loginParseWithFaceBookAccesstoken:[FBSDKAccessToken currentAccessToken]];
                            //[self requestMoreFacebookInfoForParseUser:[PFUser currentUser]];
                            
                        } else {
                            
                            [selfBlock userLoggedIn:[PFUser currentUser] token:[AuthenFacebook accessTokenFB] isFBToken:YES];
                        }
                    } else {
                        
                        [Common showAlertView:APP_NAME message:@"Skope need your email address!" delegate:selfBlock cancelButtonTitle:ALERTVIEW_OK_BUTTON arrayTitleOtherButtons:@[@"Not now"] tag:88];
                    }
                } else {
                    
                }
            }];
            
        } else {
            //Logout user and clear FBSEssion
            [[AuthenFacebook sharedAuthenFacebook] clearAllDataAndLogoutAllAccount];
        }
    }
    
    if (alertView.tag == 77) {
        
        if (buttonIndex == 0) {
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
    }
    
    [Common hideLoadingViewGlobal];

}


- (IBAction)actionLoginFB:(id)sender {
    
    __weak __typeof(self)weakSelf = self;
    typeof(self) selfBlock = weakSelf;
    
    [[AuthenFacebook sharedAuthenFacebook] beginAuthenFBWithCompletion:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        
        [Common hideLoadingViewGlobal];
        
        if (error) {
            
            NSLog(@"beginAuthenFBWithCompletion Token String: %@",[FBSDKAccessToken currentAccessToken].tokenString);
            
            //===Have error
            
            [[AuthenFacebook sharedAuthenFacebook] clearAllDataAndLogoutAllAccount];
            
            [selfBlock enableLoginButtons];
            
            NSLog(@"FBSDKGraphRequestErrorHTTPStatusCodeKey: %@",[[error userInfo] objectForKey:@"com.facebook.sdk:FBSDKGraphRequestErrorHTTPStatusCodeKey"]);
            NSLog(@"FBSDKGraphRequestErrorErrorSubcode: %@",[[error userInfo] objectForKey:@"com.facebook.sdk:FBSDKGraphRequestErrorErrorSubcode"]);
            NSLog(@"FBSDKGraphRequestErrorErrorCode: %@",[[error userInfo] objectForKey:@"com.facebook.sdk:FBSDKGraphRequestErrorErrorCode"]);
            NSLog(@"FBSDKGraphRequestErrorCategoryKey: %@",[[error userInfo] objectForKey:@"com.facebook.sdk:FBSDKGraphRequestErrorCategoryKey"]);
            NSLog(@"FBSDKErrorLocalizedTitleKey: %@",[[error userInfo] objectForKey:@"com.facebook.sdk:FBSDKErrorLocalizedTitleKey"]);
            NSLog(@"FBSDKErrorLocalizedDescriptionKey: %@",[[error userInfo] objectForKey:@"com.facebook.sdk:FBSDKErrorLocalizedDescriptionKey"]);
            NSLog(@"FBSDKErrorDeveloperMessageKey: %@",[[error userInfo] objectForKey:@"com.facebook.sdk:FBSDKErrorDeveloperMessageKey"]);
            
            
            [Common showAlertView:@"Facebook" message:[[error userInfo] objectForKey:@"com.facebook.sdk:FBSDKErrorLocalizedDescriptionKey"] delegate:nil cancelButtonTitle:ALERTVIEW_OK_BUTTON arrayTitleOtherButtons:nil tag:0];
            
        } else if (result.isCancelled) {
            
            [[AuthenFacebook sharedAuthenFacebook] clearAllDataAndLogoutAllAccount];
            
            [selfBlock enableLoginButtons];
            
            // The user cancelled the Facebook login
            
            [Common showAlertView:APP_NAME message:MSS_NEED_LOGIN delegate:nil cancelButtonTitle:ALERTVIEW_OK_BUTTON arrayTitleOtherButtons:nil tag:0];
            
        } else {
            
            if (![[FBSDKAccessToken currentAccessToken] hasGranted:@"email"]) {
                
                // Have no email permission
                
                [Common showAlertView:APP_NAME message:@"Skope need your email address!" delegate:selfBlock cancelButtonTitle:ALERTVIEW_OK_BUTTON arrayTitleOtherButtons:@[@"Not now"] tag:88];
                
            } else {
                
                NSLog(@"Result after login permission: %@",((FBSDKLoginManagerLoginResult *)result).grantedPermissions);
                
                // Have email =>> log to main server
                
                // Get UserInfo and check if ParseUser is Exist
                
                FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:FACEBOOK_GRAPH_API_FOR_ME_2_4
                                                                               parameters:nil];
                [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                    
                    // Handle results or error of request.
                    
                    NSLog(@"FACEBOOK_GRAPH_API_FOR_ME_2_4 Token String: %@",[FBSDKAccessToken currentAccessToken].tokenString);
                    
                    if (!error)
                    {
                        NSDictionary *fb_UserInfo = (NSDictionary *)result;
                        
                        // check email has exist or not
                        
                        PFQuery *query = [PFUser query];
                        
                        [query whereKey:@"emailCopy" equalTo:fb_UserInfo[@"email"]];
                        
                        [query getFirstObjectInBackgroundWithBlock:^(PFObject *PF_NULLABLE_S object,  NSError *PF_NULLABLE_S error){
                            
                            PFUser *exitUser = (PFUser *)object;
                            
                            if (!exitUser) {
                                
                                [selfBlock loginParseWithFaceBookAccesstoken:[FBSDKAccessToken currentAccessToken]];
                            }
                            else
                            {
                                // unlink user with fB and link with exist user
                                
                                // Email is exit => User Loged In with Facebook Before
                                
                                NSString *validTokenString = [AuthenFacebook accessTokenFB];
                                
                                [PFUser logInWithUsernameInBackground:exitUser.username password:PARSE_DEFAULT_PASSWORD block:^(PFUser *user, NSError *error){
                                    
                                    NSLog(@"logInWithUsernameInBackground Token String: %@",[FBSDKAccessToken currentAccessToken].tokenString);
                                    
                                    if (!error) {
                                        
                                        [Common hideLoadingViewGlobal];
                                        
                                        if (error == nil)
                                        {
                                            
                                            [selfBlock userLoggedIn:[PFUser currentUser] token:validTokenString isFBToken:YES];
                                        }
                                        else
                                        {
                                            [[AuthenFacebook sharedAuthenFacebook] clearAllDataAndLogoutAllAccount];
                                        }
                                        
                                    } else
                                    {
                                        
                                        [Common hideLoadingViewGlobal];
                                        
                                        [[AuthenFacebook sharedAuthenFacebook] clearAllDataAndLogoutAllAccount];
                                        
                                        [selfBlock enableLoginButtons];
                                        
                                        [Common showAlertView:APP_NAME message:MSS_LOGIN_TRY_AGAIN delegate:selfBlock cancelButtonTitle:ALERTVIEW_OK_BUTTON arrayTitleOtherButtons:nil tag:0];
                                    }
                                    
                                }];
                                
                            }
                        }];
                        
                    }
                    else
                    {
                        [[AuthenFacebook sharedAuthenFacebook] clearAllDataAndLogoutAllAccount];
                        
                        //[self handleRequestPermissionInfoAPICallError:error];
                        
                        //NSLog(@"Failed to fetch Facebook user data.");
                    }
                }];
            }
        }
    } fromViewController:self];
}

- (IBAction)actionLoginLK:(id)sender {
    
    __weak __typeof(self)weakSelf = self;
    typeof(self) selfBlock = weakSelf;
    
    [[AuthenLinkedIn sharedAuthenLinkedIn] loginLinkedInWithCompletion:^(BOOL success, NSDictionary *accessToken, NSError *error) {
        
        if (success) {
            
            //Login to mainServer with LinkedIn Token
            
            NSTimeInterval expires_in = [accessToken[@"expires_in"] doubleValue]*1000 + [NSDate timeIntervalSinceReferenceDate]; //To mili second
            [[UserDefault currentUser] setOriginal_ln_token_expired_at:[NSString stringWithFormat:@"%f",expires_in]];
            [[UserDefault currentUser] setOriginal_ln_token:accessToken[@"access_token"]];
            
            NSString *accessTokenString = accessToken[@"access_token"];
            
            [[AuthenLinkedIn sharedAuthenLinkedIn] requestMeWithToken:accessTokenString completion:^(BOOL success, NSDictionary *userInfo) {
                
                if (success) {
                    
                    [selfBlock loginToMainServerWithLKToken:accessTokenString completion:^(AFHTTPRequestOperation *operation, id responseObject) {
                        
                        if ([Common validateResponse:responseObject]) {
                            
                            NSDictionary *data = responseObject[@"data"];
                            NSDictionary *accessTokenServer = data[@"accessToken"];
                            NSDictionary *main_user = data[@"user"];
                            
                            
                            [selfBlock loginParseWithLKUserInfo:main_user completion:^(PFUser *user, NSError *error) {
                                
                                if (!error) {
                                    
                                    [selfBlock updateLinkedInUserInfoToParseForPFUser:user withLKUserInfoFromMainServer:main_user completion:^(BOOL succeeded, NSError *error) {
                                        
                                        if (!error)
                                        {
                                            [Common hideLoadingViewGlobal];
                                            
                                            //Cache userInfo and goto mainVC
                                            
                                            if (accessTokenServer[@"token"]) {
                                                
                                                [[UserDefault currentUser] setLn_token:accessTokenServer[@"token"]];
                                                [[UserDefault currentUser] setFb_token:nil];
   
                                            }
                                            if (main_user) {
                                                
                                                [UserDefault setUser:main_user];
                                                [AppDelegate sendDeviceTokenToServer:[[ISDiskCache sharedCache] objectForKey:APP_DEVICE_TOKEN]];
                                                
                                                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_USER_LOGGED_IN object:nil userInfo:nil];
                                                
                                            }
                                            
                                        }
                                        else
                                        {
                                            [Common hideLoadingViewGlobal];
                                            
                                            [[AuthenFacebook sharedAuthenFacebook] clearAllDataAndLogoutAllAccount];
                                            
                                            [selfBlock enableLoginButtons];
                                            
                                            NSString *errorMsg = [Common errorMessageFromResponseObject:responseObject];
                                            
                                            [Common showAlertView:APP_NAME message:errorMsg?errorMsg:MSS_LOGIN_TRY_AGAIN delegate:selfBlock cancelButtonTitle:ALERTVIEW_OK_BUTTON arrayTitleOtherButtons:nil tag:0];
                                        }
                                    }];
                                    
                                    /*
                                     if ([userInfo[@"fb_id"] isEqual:[NSNull null]] || ((NSString*)userInfo[@"fb_id"]).length == 0) {
                                     
                                     //Have no fb_id => new user from LK
                                     
                                     } else {
                                     
                                     //User loged in with the same email in facebook
                                     
                                     }
                                     */
                                    
                                } else
                                {
                                    
                                    [Common hideLoadingViewGlobal];
                                    
                                    [[AuthenFacebook sharedAuthenFacebook] clearAllDataAndLogoutAllAccount];
                                    
                                    [selfBlock enableLoginButtons];
                                    
                                    NSString *errorMsg = [Common errorMessageFromResponseObject:responseObject];
                                    
                                    [Common showAlertView:APP_NAME message:errorMsg?errorMsg:MSS_LOGIN_TRY_AGAIN delegate:selfBlock cancelButtonTitle:ALERTVIEW_OK_BUTTON arrayTitleOtherButtons:nil tag:0];
                                }
                            }];
                            
                        }
                        else
                        {
                            [Common hideLoadingViewGlobal];
                            
                            [[AuthenFacebook sharedAuthenFacebook] clearAllDataAndLogoutAllAccount];
                            
                            [selfBlock enableLoginButtons];
                            
                            NSString *errorMsg = [Common errorMessageFromResponseObject:responseObject];
                            
                            [Common showAlertView:APP_NAME message:errorMsg?errorMsg:MSS_LOGIN_TRY_AGAIN delegate:selfBlock cancelButtonTitle:ALERTVIEW_OK_BUTTON arrayTitleOtherButtons:nil tag:0];
                        }
                    }];
                    
                }
                else
                {
                    
                    [Common hideLoadingViewGlobal];
                    
                    [[AuthenFacebook sharedAuthenFacebook] clearAllDataAndLogoutAllAccount];
                    
                    [selfBlock enableLoginButtons];
                    
                    [Common showAlertView:APP_NAME message:MSS_LOGIN_TRY_AGAIN delegate:selfBlock cancelButtonTitle:ALERTVIEW_OK_BUTTON arrayTitleOtherButtons:nil tag:0];
                }
                
                
            }];
            
        } else if (!error) {
            
            [selfBlock enableLoginButtons];
            
            //Show alertView to require login
            [Common showAlertView:APP_NAME message:MSS_NEED_LOGIN delegate:nil cancelButtonTitle:ALERTVIEW_OK_BUTTON arrayTitleOtherButtons:nil tag:0];
            
        } else {
            
            [selfBlock enableLoginButtons];

            [Common showAlertView:HAVE_AN_ERROR message:MSS_TRY_AGAIN delegate:nil cancelButtonTitle:ALERTVIEW_OK_BUTTON arrayTitleOtherButtons:nil tag:0];
        }
    }];
}

- (void)enableLoginButtons {
    
    [self.btn_login_LK setHidden:NO];
    [self.btn_login_FB setHidden:NO];
    
    self.btn_login_FB.alpha = 0.0;
    self.btn_login_LK.alpha = 0.0;
    
    [UIView animateWithDuration:0.8 delay:1.2 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        [self.lbl_containerView setCenter:CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds) - 100)];
        
        [self.btn_containerView setCenter:CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds) + 100)];
        
        self.btn_login_FB.alpha = 1.0;
        self.btn_login_LK.alpha = 1.0;
        
    } completion:^(BOOL finished) {
        //
    }];
}

- (void)disableLoginButtons {
    [self.btn_login_LK setHidden:YES];
    [self.btn_login_FB setHidden:YES];
}


#pragma mark - TTTAttributedLabelDelegate

- (void)createAttributeLableForTermsAndPolicy {
    
    NSString *summaryText = @"By continuing, you agree to the Terms of Service and Privacy Policy";
    
    self.summaryLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
    self.summaryLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0f];
    self.summaryLabel.textColor = [UIColor whiteColor];
    self.summaryLabel.lineBreakMode = UILineBreakModeWordWrap;
    self.summaryLabel.numberOfLines = 0;
    self.summaryLabel.textAlignment = NSTextAlignmentCenter;
    self.summaryLabel.linkAttributes = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:(__bridge NSString *)kCTUnderlineStyleAttributeName];
    
    NSMutableDictionary *mutableActiveLinkAttributes = [NSMutableDictionary dictionary];
    [mutableActiveLinkAttributes setValue:[NSNumber numberWithBool:NO] forKey:(NSString *)kCTUnderlineStyleAttributeName];
    [mutableActiveLinkAttributes setValue:(__bridge id)[APP_COMMON_GREEN_COLOR CGColor] forKey:(NSString *)kCTForegroundColorAttributeName];
    [mutableActiveLinkAttributes setValue:(__bridge id)[[UIColor colorWithWhite:1.0f alpha:0.1f] CGColor] forKey:(NSString *)kTTTBackgroundFillColorAttributeName];
    [mutableActiveLinkAttributes setValue:(__bridge id)[[UIColor colorWithWhite:1.0f alpha:0.25f] CGColor] forKey:(NSString *)kTTTBackgroundStrokeColorAttributeName];
    [mutableActiveLinkAttributes setValue:[NSNumber numberWithFloat:1.0f] forKey:(NSString *)kTTTBackgroundLineWidthAttributeName];
    [mutableActiveLinkAttributes setValue:[NSNumber numberWithFloat:2.0f] forKey:(NSString *)kTTTBackgroundCornerRadiusAttributeName];
    self.summaryLabel.activeLinkAttributes = mutableActiveLinkAttributes;
    
    self.summaryLabel.highlightedTextColor = [UIColor whiteColor];
    //    self.summaryLabel.shadowColor = [UIColor colorWithWhite:0.87f alpha:1.0f];
    //    self.summaryLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
    //    self.summaryLabel.highlightedShadowColor = [UIColor colorWithWhite:0.0f alpha:0.25f];
    //    self.summaryLabel.highlightedShadowOffset = CGSizeMake(0.0f, -1.0f);
    //    self.summaryLabel.highlightedShadowRadius = 1;
    self.summaryLabel.verticalAlignment = TTTAttributedLabelVerticalAlignmentTop;
    
    [self.summaryLabel setText:summaryText afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        
        NSString *string = [mutableAttributedString string];
        
        NSRange nameRange = [string rangeOfString:@"Terms of Service"];
        
        UIFont *HelveticaNeueFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15.0f];
        
        CTFontRef boldFont = CTFontCreateWithName((__bridge CFStringRef)HelveticaNeueFont.fontName, HelveticaNeueFont.pointSize, NULL);
        
        if (boldFont) {
            
            [mutableAttributedString removeAttribute:(__bridge NSString *)kCTFontAttributeName range:nameRange];
            [mutableAttributedString addAttribute:(__bridge NSString *)kCTFontAttributeName value:(__bridge id)boldFont range:nameRange];
            CFRelease(boldFont);
            
            [mutableAttributedString removeAttribute:(NSString *)kCTForegroundColorAttributeName range:nameRange];
            [mutableAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(__bridge id)[[UIColor whiteColor] CGColor] range:nameRange];
        }
        
        [mutableAttributedString replaceCharactersInRange:nameRange withString:[string substringWithRange:nameRange]];
        
        NSRange policyRange = [string rangeOfString:@"Privacy Policy"];
        
        CTFontRef italicFont = CTFontCreateWithName((__bridge CFStringRef)HelveticaNeueFont.fontName, HelveticaNeueFont.pointSize, NULL);
        
        if (italicFont) {
            
            [mutableAttributedString removeAttribute:(NSString *)kCTFontAttributeName range:policyRange];
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)italicFont range:policyRange];
            CFRelease(italicFont);
            
            [mutableAttributedString removeAttribute:(NSString *)kCTForegroundColorAttributeName range:policyRange];
            [mutableAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(__bridge id)[[UIColor whiteColor] CGColor] range:policyRange];
        }
        
        return mutableAttributedString;
    }];
    
    
    // Add URL to label
    
    NSURL *terms_url = [NSURL URLWithString:[NSString stringWithFormat:APP_Terms_of_Service]];
    NSURL *services_url = [NSURL URLWithString:[NSString stringWithFormat:APP_Privacy_Policy]];
    
    NSRange termRange = [summaryText rangeOfString:@"Terms of Service"];
    [self.summaryLabel addLinkToURL:terms_url withRange:termRange];
    
    NSRange policyRange = [summaryText rangeOfString:@"Privacy Policy"];
    [self.summaryLabel addLinkToURL:services_url withRange:policyRange];
    
    // Add label to view
    
    [self.summaryLabel setDelegate:self];
    
    [self.summaryLabel setNeedsDisplay];
    
    self.summaryLabel.frame = self.agreeTextContainerView.bounds;
    
    [self.agreeTextContainerView addSubview:self.summaryLabel];
    
}

- (void)attributedLabel:(__unused TTTAttributedLabel *)label
   didSelectLinkWithURL:(NSURL *)url {
    
    SVModalWebViewController *webViewController = [[SVModalWebViewController alloc] initWithAddress:[url absoluteString]];
    [self presentViewController:webViewController animated:YES completion:NULL];

}

@end
