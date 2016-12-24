//
//  AppDelegate.m
//  Skope
//
//  Created by CHAU HUYNH on 2/10/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import "AppDelegate.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "MLBlackTransition.h"
#import "lelib.h"
#import "MainViewController.h"

typedef void(^getNotificationCountCompletion)(BOOL success, id response);

@interface AppDelegate ()<JFMinimalNotificationDelegate>

@property (nonatomic, strong) JFMinimalNotification *notification;

- (void)setupStream;
- (void)goOnline;
- (void)goOffline;

@end

@implementation AppDelegate


+ (OLGhostAlertView *)sharedReachabilityAlert {
    static OLGhostAlertView *_sharedReachabilityAlert = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _sharedReachabilityAlert = [[OLGhostAlertView alloc] initWithTitle:/*@"Check out the code."*/nil message:@"No Internet Connection" timeout:HUGE_VAL dismissible:YES];
        
        _sharedReachabilityAlert.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:19.0f];
        _sharedReachabilityAlert.messageLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0f];
        _sharedReachabilityAlert.style = OLGhostAlertViewStyleDark;
        _sharedReachabilityAlert.bottomContentMargin = 10.0;
        _sharedReachabilityAlert.completionBlock = ^(void) {
            
        };
        //[_sharedReachabilityAlert show];
    });
    
    return _sharedReachabilityAlert;
}

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    //  Init LogEntried
    
    
    LELog* log = [LELog sharedInstance];
    log.token = LOGENTRIED_TOKEN;
    log.logApplicationLifecycleNotifications = YES;
    
    [Fabric with:@[CrashlyticsKit]];
    
    
    
    //  Init isKilled app is NO for background location tracking
    
    isKilledAppProcess = NO;
    
    self.shareModel = [LocationShareModel sharedModel];
    self.shareModel.afterResume = NO;
    
    if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusDenied) {
        
        [Common showAlertView:APP_NAME message:@"The app doesn't work without the Background App Refresh enabled. To turn it on, go to Settings > General > Background App Refresh" delegate:nil cancelButtonTitle:ALERTVIEW_OK_BUTTON arrayTitleOtherButtons:nil tag:0];
        
    } else if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusRestricted) {
        
        [Common showAlertView:APP_NAME message:@"The functions of this app are limited because the Background App Refresh is disable." delegate:nil cancelButtonTitle:ALERTVIEW_OK_BUTTON arrayTitleOtherButtons:nil tag:0];
        
    } else {
        
        if ([launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey]) {
            
            //NSLog(@"UIApplicationLaunchOptionsLocationKey");
            
            //App forced relaunch by system when receive new event about location
            
            isKilledAppProcess = YES;
            
            // This "afterResume" flag is just to show that he receiving location updates
            // are actually from the key "UIApplicationLaunchOptionsLocationKey"
            self.shareModel.afterResume = YES;
            
            self.shareModel.anotherLocationManager = [[CLLocationManager alloc]init];
            self.shareModel.anotherLocationManager.delegate = self;
            self.shareModel.anotherLocationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
            self.shareModel.anotherLocationManager.activityType = CLActivityTypeOtherNavigation;
            
            if(IS_OS_8_OR_LATER) {
                [self.shareModel.anotherLocationManager requestAlwaysAuthorization];
            }
            
            [self.shareModel.anotherLocationManager startMonitoringSignificantLocationChanges];
        }
        
        /*
         self.locationTracker = [[LocationTracker alloc]init];
         [self.locationTracker startLocationTracking];
         
         
         //Send the best location to server every TIME_TO_RECALL_WS_UPDATE_LOCATION seconds
         //You may adjust the time interval depends on the need of your app.
         
         NSTimeInterval time = TIME_TO_RECALL_WS_UPDATE_LOCATION;
         self.locationUpdateTimer =
         [NSTimer scheduledTimerWithTimeInterval:time
         target:self
         selector:@selector(updateLocation)
         userInfo:nil
         repeats:YES];
         */
    }
    
    //    [QBApplication sharedApplication].applicationId = 22129;
    //    [QBConnection registerServiceKey:@"gTEJ7HKRk8usjMO"];
    //    [QBConnection registerServiceSecret:@"ADjwzF6rz2bQ5r-"];
    //    [QBSettings setAccountKey:@"GBwNUT5exXP7cRQdUyeC"];
    //    [QBChat instance].autoReconnectEnabled = YES;
    //
    //    [QBRequest createSessionWithSuccessBlock:^(QBResponse *response, QBASession *session) {
    //    } errorBlock:^(QBResponse *response) {
    //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", "")
    //                                                        message:[response.error description]
    //                                                       delegate:nil
    //                                              cancelButtonTitle:NSLocalizedString(@"OK", "")
    //                                              otherButtonTitles:nil];
    //        [alert show];
    //    }];
    
    
    //  Parse configuration
    
    [Parse enableLocalDatastore];
    [PFUser enableAutomaticUser];
    [PFUser enableRevocableSessionInBackground];
    [Parse setApplicationId:PARSE_APPLICATION_ID clientKey:PARSE_CLIENT_ID];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    [PFFacebookUtils initializeFacebookWithApplicationLaunchOptions:launchOptions];
    [PFImageView class];
    
    
    
    //  Added by Nguyen Truong Luu for swipe to pop UINavigationController
    
    //[MLBlackTransition validatePanPackWithMLBlackTransitionGestureRecognizerType:MLBlackTransitionGestureRecognizerTypePan];
    
    
    
    //  For notifications
    
    [self registerRemoteNotificationForApplication:application];
    
    if (launchOptions) {
        
        UILocalNotification *notification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        
        if (notification) {

            [self application:application didReceiveRemoteNotification:(NSDictionary*)notification];
            
        }
    }
    
    
    //  For Reachability
    
    [[NTLReachabilityManager sharedManager] reachability].reachableBlock = ^(Reachability *reachability) {
        NSLog(@"Network is reachable.");
        
        if (kAllowAutoDetectConnectionAndRefreshData) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kInternetConnectionIsEnableNotification object:nil];
            [[AppDelegate sharedReachabilityAlert] hide];
        }

    };
    
    
    [[NTLReachabilityManager sharedManager] reachability].unreachableBlock = ^(Reachability *reachability) {
        NSLog(@"Network is unreachable.");
        
        if (kAllowAutoDetectConnectionAndRefreshData) {
            [[AppDelegate sharedReachabilityAlert] showInView:[[[UIApplication sharedApplication] delegate] window]];
        }
        
    };
    
    //  For SVProgressHUD
    
    [SVProgressHUD setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.95]];
    [SVProgressHUD setForegroundColor:[UIColor blackColor]];
    
    
    //  For JSBadgeView
    
    [[JSBadgeView appearance] setBadgeBackgroundColor:[UIColor redColor]];
    [[JSBadgeView appearance] setBadgeAlignment:JSBadgeViewAlignmentTopRight];
    [[JSBadgeView appearance] setBadgeTextFont:FONT_TEXT_BAGED_MESSAGE_COUNT];
    
    
    //  LoginSuccess Notification
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadUserInappNotificationCount) name:NOTIFICATION_USER_LOGGED_IN object:nil];
    
    //  FacebookSDK
    
    [FBSDKProfile enableUpdatesOnAccessTokenChange:YES];
    
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                    didFinishLaunchingWithOptions:launchOptions];
}

- (void)loadUserInappNotificationCount {
    
    [AppDelegate getUserNotificationNumberFromServerCompletion:^(BOOL success, id response) {
        
        if ([Common validateResponse:response]) {
            
            NSDictionary *items = response[@"data"][@"items"];
            
            NSUInteger newComments = [items[@"new-comment"] integerValue];
            NSUInteger newLikes = [items[@"new-like"] integerValue];
            NSUInteger newPosts = [items[@"new-post"] integerValue];
            NSUInteger newMessages = [items[@"new-message"] integerValue];
            
            if (newPosts > [[[UserDefault currentUser] postBagedNumber] integerValue]) {
                [UserDefault currentUser].haveNewPostNotification = @"1";
                [[NSNotificationCenter defaultCenter] postNotificationName:NEW_POST_NOTIFICATION object:nil];
            }
            
            [[UserDefault currentUser] setCommentBagedNumber:[NSString stringWithFormat:@"%lu",newComments+newLikes]];
            [[UserDefault currentUser] setMessageBagedNumber:[NSString stringWithFormat:@"%lu",newMessages]];
            [[UserDefault currentUser] setPostBagedNumber:[NSString stringWithFormat:@"%lu",newPosts]];
            
            [UserDefault performCache];
            
            [AppDelegate updateAppIconBadgedNumber];
            
            
        } else {
            switch ([Common responseStatusCode:response]) {
                case 400:
                    //
                    break;
                case 403:
                    //
                    break;
                case 406:
                    //
                    break;
                default:
                    break;
            }
        }
    }];
    
    [AppDelegate getCurrentUserProfileInfoFromWebServiceWithCompletion:^(BOOL success, id response) {
        
        if (success && response) {
            
            NSMutableDictionary *userProfileInfo = response[@"data"][@"user"];
            [UserDefault setUser:userProfileInfo];
            
        } else {
            
        }
        
    }];
}

//===Notifications


- (void)registerRemoteNotificationForApplication:(UIApplication*)application
{
    if ([NTLReachabilityManager isReachable]) {
        if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
            UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge|UIUserNotificationTypeSound|UIUserNotificationTypeAlert) categories:nil];
            [application registerUserNotificationSettings:settings];
        } else {
            //UIUserNotificationType myTypes = UIUserNotificationTypeBadge|UIUserNotificationTypeSound| UIUserNotificationTypeAlert;
            //[application registerForRemoteNotificationTypes:myTypes];
            [application registerForRemoteNotifications];
        }
    }
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    //handle the actions
    if ([identifier isEqualToString:@"declineAction"]){
        
    }
    else if ([identifier isEqualToString:@"answerAction"]){
        
    }
}

//#ifdef __IPHONE_8_0
//- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
//{
//    //register to receive notifications
//    [application registerForRemoteNotifications];
//}
//
//- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
//{
//    //handle the actions
//    if ([identifier isEqualToString:@"declineAction"]){
//    }
//    else if ([identifier isEqualToString:@"answerAction"]){
//    }
//}
//#endif


//===Done for notification

-(void)updateLocation {
    [self.locationTracker updateLocationToServer];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    //NSLog(@"locationManager didUpdateLocations Appdelegate: %@",locations);
    
    for(int i=0;i<locations.count;i++){
        CLLocation * newLocation = [locations objectAtIndex:i];
        CLLocationCoordinate2D theLocation = newLocation.coordinate;
        CLLocationAccuracy theAccuracy = newLocation.horizontalAccuracy;
        
        self.location = theLocation;
        self.locationAccuracy = theAccuracy;
    }
    
    //Call WS for updating location...
    //Call if isKilledAppprocess = YES, when app is relaunched by system after app is terminated by user
    if (CLLocationCoordinate2DIsValid(self.location) && [[UserDefault currentUser].server_access_token length] > 0 && isKilledAppProcess) {
        [self callWSUpdateLocationWhenAppKilled:self.location];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
    //    [self disconnect];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    [self.shareModel.anotherLocationManager stopMonitoringSignificantLocationChanges];
    
    if(IS_OS_8_OR_LATER) {
        [self.shareModel.anotherLocationManager requestAlwaysAuthorization];
    }
    [self.shareModel.anotherLocationManager startMonitoringSignificantLocationChanges];
    //    [[QBChat instance] logout];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:APP_DID_BACKGROUND_NOTIFICATION object:nil];
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    //login QuickBlox with user infor
    //    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //
    //    NSString *userLogin = [defaults objectForKey:@"loginQuickbloxID"];
    //    NSString *userPassword = [defaults objectForKey:@"passwordQuickblox"];
    //
    //    QBSessionParameters *parameters = [QBSessionParameters new];
    //    parameters.userLogin = userLogin;
    //    parameters.userPassword = userPassword;
    //
    //    [QBRequest createSessionWithExtendedParameters:parameters successBlock:^(QBResponse *response, QBASession *session) {
    //        // Sign In to QuickBlox Chat
    //        QBUUser *currentUser = [QBUUser user];
    //        currentUser.ID = session.userID; // your current user's ID
    //        currentUser.password = userPassword; // your current user's password
    //
    //        // login to Chat
    //        [[QBChat instance] loginWithUser:currentUser];
    //        NSLog(@"successBlock: %@", response);
    //    } errorBlock:^(QBResponse *response) {
    //        // error handling
    //        NSLog(@"errorBlock: %@", response.error);
    //    }];
    //
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    //Remove the "afterResume" Flag after the app is active again.
    
    self.shareModel.afterResume = NO;
    
    if(self.shareModel.anotherLocationManager)
        [self.shareModel.anotherLocationManager stopMonitoringSignificantLocationChanges];
    
    self.shareModel.anotherLocationManager = [[CLLocationManager alloc]init];
    self.shareModel.anotherLocationManager.delegate = self;
    self.shareModel.anotherLocationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    self.shareModel.anotherLocationManager.activityType = CLActivityTypeOtherNavigation;
    
    if(IS_OS_8_OR_LATER) {
        [self.shareModel.anotherLocationManager requestAlwaysAuthorization];
    }
    [self.shareModel.anotherLocationManager startMonitoringSignificantLocationChanges];
    //    [self connect];
    
    [FBSDKAppEvents activateApp];

    //  2:Get InappNotificationCount From server
    
    [self loadUserInappNotificationCount];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:APP_DID_ACTIVE_NOTIFICATION object:nil];
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    //    [[QBChat instance] logout];
    
    [self saveContext];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.chauhuynh.gcs.Skope" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Skope" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Skope.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        //NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            //NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - FACEBOOK SECTION


- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return YES;//[[PFFacebookUtils session] handleOpenURL:url];
}

#pragma mark - Push notification methods

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    
    __block NSString *tokenString   = [deviceToken description];

    tokenString                     = [tokenString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    tokenString                     = [tokenString stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    [[ISDiskCache sharedCache] setObject:tokenString forKey:APP_DEVICE_TOKEN];
    
    [[UserDefault currentUser] setCurrentDeviceToken:tokenString];
    
    [UserDefault performCache];
    
    // Send device token to Server
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [AppDelegate sendDeviceTokenToServer:tokenString];
        
        NSLog(@"tokenString: %@",tokenString);
        
    });
    
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    // Reset device token when error
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [[ISDiskCache sharedCache] setObject:@"" forKey:APP_DEVICE_TOKEN];
        
        [AppDelegate sendDeviceTokenToServer:@""];
        
    });
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    
    //  1:Update inApp badge number
    
    [self updateInAppBagedNumberFromRemoteNotification:userInfo updateUI:YES];

    //  2:updateAppIconBadgedNumber
    
    [AppDelegate updateAppIconBadgedNumber];
    
    if (application.applicationState == UIApplicationStateInactive || application.applicationState == UIApplicationStateBackground) {
        
    } else {
        
        //Receive notification when app running => do not change app icon baged

        NSString *alertType = [userInfo valueForKey:@"type"];
        
        if ([alertType isEqualToString:@"new-post"]) {
            
            [UserDefault currentUser].haveNewPostNotification = @"1";
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NEW_POST_NOTIFICATION object:nil userInfo:nil];
            
            
            // Show alert banner in window
            
            self.notification = [JFMinimalNotification notificationWithStyle:JFMinimalNotificationStyleError title:APP_NAME subTitle:[[userInfo valueForKey:@"aps"] valueForKey:@"alert"] dismissalDelay:2.5 touchHandler:^{
                
                [self.notification dismiss];
                self.notification = nil;
                
            }];
            
            [self.notification setDelegate:self];
            [self.notification setPresentFromTop:YES];
            [self.notification setStyle:JFMinimalNotificationStyleInfo animated:YES];
            [self.notification setTitleFont:FONT_NOTIFICATION_TITLE];
            [self.notification setSubTitleFont:FONT_NOTIFICATION_CONTENT];
            
            [self.window addSubview:self.notification];
            
            [self.notification show];
            
        } else if ([alertType isEqualToString:@"new-comment"] || [alertType isEqualToString:@"new-like"]) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NEW_COMMENT_LIKE_NOTIFICATION object:nil userInfo:nil];
            
            
            // Show alert banner in window
            
            self.notification = [JFMinimalNotification notificationWithStyle:JFMinimalNotificationStyleError title:APP_NAME subTitle:[[userInfo valueForKey:@"aps"] valueForKey:@"alert"] dismissalDelay:2.5 touchHandler:^{
                
                [self.notification dismiss];
                self.notification = nil;
                
            }];
            
            [self.notification setDelegate:self];
            [self.notification setPresentFromTop:YES];
            [self.notification setStyle:JFMinimalNotificationStyleInfo animated:YES];
            [self.notification setTitleFont:FONT_NOTIFICATION_TITLE];
            [self.notification setSubTitleFont:FONT_NOTIFICATION_CONTENT];
            
            [self.window addSubview:self.notification];
            
            [self.notification show];
            
        } else if ([alertType isEqualToString:@"new-message"]) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NEW_MSG_NOTIFICATION object:nil userInfo:nil];
            
            UIViewController *lastVC = self.window.visibleViewController;
            
            if ([lastVC isKindOfClass:[ChatViewController class]] || ([lastVC isKindOfClass:[MainViewController class]] && ((MainViewController*)lastVC).currentViewControllerType == PageViewControllerTypeChatView)) {
                
            } else {
                
                // Show alert banner in window
                
                self.notification = [JFMinimalNotification notificationWithStyle:JFMinimalNotificationStyleError title:APP_NAME subTitle:[[userInfo valueForKey:@"aps"] valueForKey:@"alert"] dismissalDelay:2.5 touchHandler:^{
                    
                    [self.notification dismiss];
                    self.notification = nil;
                    
                }];
                
                [self.notification setDelegate:self];
                [self.notification setPresentFromTop:YES];
                [self.notification setStyle:JFMinimalNotificationStyleInfo animated:YES];
                [self.notification setTitleFont:FONT_NOTIFICATION_TITLE];
                [self.notification setSubTitleFont:FONT_NOTIFICATION_CONTENT];
                
                [self.window addSubview:self.notification];
                
                [self.notification show];
                
            }
            
        }
        

    }
}

- (void)updateInAppBagedNumberFromRemoteNotification:(NSDictionary*)userInfo updateUI:(BOOL)updateUI {
    
    NSString *alertType = [userInfo valueForKey:@"type"];
    
    NSInteger newbagednumber = 0;
    
    if ([alertType isEqualToString:@"new-comment"] || [alertType isEqualToString:@"new-like"]) {
        
        newbagednumber = [[UserDefault currentUser].commentBagedNumber integerValue] + 1;
        [[UserDefault currentUser] setCommentBagedNumber:[NSString stringWithFormat:@"%ld",(long)newbagednumber]];
        MainViewController *mainVC = (MainViewController *)[[(AppDelegate*)[[UIApplication sharedApplication] delegate] window] rootViewController];
        [mainVC.homeViewController updateNewCommentBagedNumber];
        
    } else if ([alertType isEqualToString:@"new-message"]) {
        
        newbagednumber = [[UserDefault currentUser].messageBagedNumber integerValue] + 1;
        [[UserDefault currentUser] setMessageBagedNumber:[NSString stringWithFormat:@"%ld",(long)newbagednumber]];
        MainViewController *mainVC = (MainViewController *)[[(AppDelegate*)[[UIApplication sharedApplication] delegate] window] rootViewController];
        [mainVC.homeViewController updateNewMessageBagedNumber];
        
    } else if ([alertType isEqualToString:@"new-post"]) {
        
        newbagednumber = [[UserDefault currentUser].postBagedNumber integerValue] + 1;
        [[UserDefault currentUser] setPostBagedNumber:[NSString stringWithFormat:@"%ld",(long)newbagednumber]];

    }
    
    [UserDefault performCache];
}

#pragma mark - Update location with app killed
- (void) callWSUpdateLocationWhenAppKilled:(CLLocationCoordinate2D) newLocation {
    
    NSString *access_token = [UserDefault currentUser].server_access_token;
    NSString *latitude = [NSString stringWithFormat:@"%f",newLocation.latitude];
    NSString *longitude = [NSString stringWithFormat:@"%f",newLocation.longitude];
    
    if (!access_token || access_token.length == 0 || !longitude || !latitude) {
        return;
    }
    
    NSString *strStatus = @"killed_app";
    
    [Common showNetworkActivityIndicator];
    AFHTTPRequestOperationManager *manager = [Common AFHTTPRequestOperationManagerReturn];
    NSDictionary *request_param = @{@"latitude":latitude,
                                    @"longitude":longitude,
                                    @"status":strStatus,
                                    @"created_date":[NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970] * 1000],
                                    };
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
    
    // Optionally for time zone conversions
    //[formatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];
    
    NSString *stringFromDate = [formatter stringFromDate:[NSDate date]];
    
    NSDictionary *request_param_2 = @{@"userName":[UserDefault currentUser].name,
                                      @"email":[UserDefault currentUser].email,
                                      @"latitude":latitude,
                                      @"longitude":longitude,
                                      @"status":strStatus,
                                      @"created_date":stringFromDate,
                                      };
    
    [[LELog sharedInstance] log:[NSString stringWithFormat: @"callWSUpdateLocationWhenAppKilled : %@",request_param_2]];
    
    [manager PUT:[NSString stringWithFormat:@"%@?access_token=%@", URL_SERVER_API(API_UPDATE_LOCATION),[UserDefault currentUser].server_access_token] parameters:request_param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [Common hideNetworkActivityIndicator];
        
        //First update when app live again after killed, here is background mode process
        isKilledAppProcess = NO;
        
        //Needed? save battery
        //if(self.shareModel.anotherLocationManager)
        //[self.shareModel.anotherLocationManager stopMonitoringSignificantLocationChanges];
        
        // NSLog(@"Tracking KILL Error: %@", responseObject);
        
        if ([Common validateResponse:responseObject]) {
            
            [UserDefault currentUser].strLat = [NSString stringWithFormat:@"%g", newLocation.latitude];
            [UserDefault currentUser].strLong = [NSString stringWithFormat:@"%g", newLocation.longitude];
            [UserDefault performCache];
            
        } else {
            
            switch ([Common responseStatusCode:responseObject]) {
                case 400:
                    //
                    break;
                    
                case 403:
                    //
                    break;
                    
                case 406:
                    //
                    break;
                    
                default:
                    break;
            }
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [Common hideNetworkActivityIndicator];
    }];
}

#pragma mark - XMPP Chat

- (void)setupStream {
    //    xmppStream = [[XMPPStream alloc] init];
    //    [xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
}

- (void)goOnline {
    //    XMPPPresence *presence = [XMPPPresence presence];
    //    [xmppStream sendElement:presence];
}

- (void)goOffline {
    //    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    //    [xmppStream sendElement:presence];
}

- (BOOL)connect {
    
    //    [self setupStream];
    //
    //    NSString *jabberID = [[NSUserDefaults standardUserDefaults] stringForKey:@"chatID"];
    //    NSString *myPassword = [[NSUserDefaults standardUserDefaults] stringForKey:@"chatPassword"];
    //
    //    if (![xmppStream isDisconnected]) {
    //        return YES;
    //    }
    //
    //    if (jabberID == nil || myPassword == nil) {
    //
    //        return NO;
    //    }
    //
    //    [xmppStream setMyJID:[XMPPJID jidWithString:jabberID]];
    //    password = myPassword;
    //
    //    NSError *error = nil;
    //    NSTimeInterval time = TIME_TO_RECALL_WS_UPDATE_LOCATION;
    //
    //    if (![xmppStream connectWithTimeout:time error:&error])
    //    {
    //        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
    //                                                            message:[NSString stringWithFormat:@"Can't connect to server %@", [error localizedDescription]]
    //                                                           delegate:nil
    //                                                  cancelButtonTitle:@"Ok"
    //                                                  otherButtonTitles:nil];
    //        [alertView show];
    //
    //
    //        return NO;
    //    }
    //
    return YES;
}

- (void)disconnect {
    
    //    [self goOffline];
    //    [xmppStream disconnect];
    
}


#pragma mark - CLASSS_METHODS


+ (void)updateAppIconBadgedNumber {
    
    NSUInteger newLikeComments = [[UserDefault currentUser].commentBagedNumber integerValue];
    NSUInteger newPosts = [[UserDefault currentUser].postBagedNumber integerValue];
    NSUInteger newMessages = [[UserDefault currentUser].messageBagedNumber integerValue];
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:newLikeComments+newPosts+newMessages];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BAGED_COUNT_CHANGED_NOTIFICATION object:nil];
}


+ (void)getCurrentUserProfileInfoFromWebServiceWithCompletion:(getCurrentUserProfileCompletion)completion {
    
    NSString *access_token = [UserDefault currentUser].server_access_token;
    NSString *userId = [UserDefault currentUser].u_id;
    
    if (!access_token || access_token.length == 0 || !userId) {
        
        completion(NO,nil);
        
    } else {
        
        AFHTTPRequestOperationManager *manager = [Common AFHTTPRequestOperationManagerReturn];
        NSDictionary *request_param = @{@"access_token":access_token,
                                        @"id":userId,
                                        };
        
        [manager GET:URL_SERVER_API(API_GET_PROFILE([UserDefault currentUser].u_id)) parameters:request_param success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            [Common requestSuccessWithReponse:responseObject didFinish:^(BOOL success, NSMutableDictionary *object) {
                if (success && object) {
                    completion(YES,object);
                } else {
                    completion(NO,nil);
                }
                
            }];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            completion(NO,nil);
            
        }];
    }

}


+ (void)resetNotificationBagedNumberToServerWithType:(kNotificationType)type {
    
    //===Reset baged number on server
    
    NSString *accessToken = [UserDefault currentUser].server_access_token;
    
    if (accessToken && accessToken.length > 0 && type > kUndefineNotificationType && type < kLastBoundNotificationType) {
        
        NSString* typeString;
        
        switch (type) {
            case kNotificationNewComment:
                typeString = @"new-comment";
                break;
            case kNotificationNewLike:
                typeString = @"new-like";
                break;
            case kNotificationNewPost:
                typeString = @"new-post";
                break;
            case kNotificationNewMessage:
                typeString = @"new-message";
                break;
            default:
                typeString = @"new-post";
                break;
        }
        
        
        NSDictionary *request_param = @{
                                        @"access_token":accessToken,
                                        @"number":@"0",
                                        @"type":typeString,
                                        };
        
        [[Common AFHTTPRequestOperationManagerReturn] PUT:URL_SERVER_API(API_RESET_NOTIFICATION) parameters:request_param success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            //NSLog(@"Reset notifiaction type :%@ result: %@", typeString,responseObject);
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            //NSLog(@"Reset notifiaction error: %@", error);
        }];
    }
}


+ (void)getUserNotificationNumberFromServerCompletion:(getNotificationCountCompletion)completion {
    
    NSString *server_access_token = [UserDefault currentUser].server_access_token;
    
    if (server_access_token && server_access_token.length > 0) {
        NSDictionary *request_param = @{
                                        @"access_token":server_access_token,
                                        };
        [[Common AFHTTPRequestOperationManagerReturn] GET:URL_SERVER_API(API_RESET_NOTIFICATION) parameters:request_param success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            completion(YES,responseObject);
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            completion(NO,error);
        }];
        
    } else {
        
        completion(NO,nil);
    }
}


+ (void)sendDeviceTokenToServer:(NSString*)deviceToken {
    
    if ([[UserDefault currentUser] isLoggedIn] && [PFUser currentUser]) {
        
        NSString *access_token = [UserDefault currentUser].server_access_token;
        
        if (access_token && access_token.length > 0 && deviceToken) {
            
            AFHTTPRequestOperationManager *manager = [Common AFHTTPRequestOperationManagerReturn];
            
            NSDictionary *request_param = @{@"access_token":access_token,
                                            @"ios_device_token":deviceToken};
            
            [manager PUT:URL_SERVER_API(API_DEVICE_TOKEN) parameters:request_param success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

                
            }];
        }
    }
}

@end
