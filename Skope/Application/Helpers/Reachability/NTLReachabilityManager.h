//
//  NTLReachabilityManage.h
//  CuoiHiDotCom
//
//  Created by Netbiz on 1/6/15.
//  Copyright (c) 2015 Toasternet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"
@class Reachability;
@interface NTLReachabilityManager : NSObject
@property (strong, nonatomic) Reachability *reachability;

#pragma mark -
#pragma mark Shared Manager
+ (NTLReachabilityManager *)sharedManager;

#pragma mark -
#pragma mark Class Methods
+ (BOOL)isReachable;
+ (BOOL)isUnreachable;
+ (BOOL)isReachableViaWWAN;
+ (BOOL)isReachableViaWiFi;
@end
