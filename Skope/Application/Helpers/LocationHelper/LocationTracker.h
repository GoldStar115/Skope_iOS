//
//  LocationTracker.h
//  Location
//
//  Created by Rick
//  Copyright (c) 2014 Location. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "LocationShareModel.h"

#import "AFNetworking.h"
#import "UIKit+AFNetworking.h"
#import "APIService.h"

@class Common;
@class UserDefault;
//#import "Common.h"
//#import "UserDefault.h"

@protocol LocationTrackerDelegate <NSObject>
- (void) locationUpdated;
@end

@interface LocationTracker : NSObject <CLLocationManagerDelegate>

@property (nonatomic) CLLocationCoordinate2D myLastLocation;
@property (nonatomic) CLLocationAccuracy myLastLocationAccuracy;

@property (strong,nonatomic) LocationShareModel * shareModel;

@property (nonatomic) CLLocationCoordinate2D myLocation;
@property (nonatomic) CLLocationAccuracy myLocationAccuracy;

@property(nonatomic,assign)id<LocationTrackerDelegate> delegate;

+ (CLLocationManager *)sharedLocationManager;

- (void)startLocationTracking;
- (void)stopLocationTracking;
- (void)updateLocationToServer;
//- (void)callWSUpdateLocation:(CLLocationCoordinate2D) newLocation;


@end
