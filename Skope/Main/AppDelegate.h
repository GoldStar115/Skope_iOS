//
//  AppDelegate.h
//  Skope
//
//  Created by CHAU HUYNH on 2/10/15.
//  Copyright (c) 2015 CHAU HUYNH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "LocationTracker.h"
#import "LocationShareModel.h"
#import "XMPPFramework.h"
#import "HomeVC.h"
#import "UIWindow+PazLabs.h"

typedef void(^getCurrentUserProfileCompletion)(BOOL success, id response);

@interface AppDelegate : UIResponder <UIApplicationDelegate,CLLocationManagerDelegate> {
    //Variable to detect killed app process
    BOOL isKilledAppProcess;
    XMPPStream *xmppStream;
    NSString *password;
    BOOL isOpen;
}

typedef NS_ENUM(NSUInteger, kNotificationType) {
    kUndefineNotificationType,
    kNotificationNewComment,
    kNotificationNewLike,
    kNotificationNewPost,
    kNotificationNewMessage,
    kLastBoundNotificationType,
};

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic) CLLocationCoordinate2D lastLocation;
@property (nonatomic) CLLocationAccuracy lastLocationAccuracy;

@property (nonatomic) CLLocationCoordinate2D location;
@property (nonatomic) CLLocationAccuracy locationAccuracy;

@property LocationTracker *locationTracker;
@property (nonatomic) NSTimer* locationUpdateTimer;

@property (strong,nonatomic) LocationShareModel * shareModel;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (BOOL)connect;
- (void)disconnect;

+ (void)updateAppIconBadgedNumber;
+ (void)resetNotificationBagedNumberToServerWithType:(kNotificationType)type;
+ (void)sendDeviceTokenToServer:(NSString*)deviceToken;
+ (void)getCurrentUserProfileInfoFromWebServiceWithCompletion:(getCurrentUserProfileCompletion)completion;

+ (id)sharedReachabilityAlert;

@end

