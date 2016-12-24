//
//  NTLReachabilityManage.m
//  CuoiHiDotCom
//
//  Created by Netbiz on 1/6/15.
//  Copyright (c) 2015 Toasternet. All rights reserved.
//

#import "NTLReachabilityManager.h"

@implementation NTLReachabilityManager
#pragma mark -
#pragma mark Default Manager
+ (NTLReachabilityManager *)sharedManager {
    static NTLReachabilityManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    
    return _sharedManager;
}

#pragma mark -
#pragma mark Memory Management
- (void)dealloc {
    // Stop Notifier
    if (_reachability) {
        [_reachability stopNotifier];
    }
}

#pragma mark -
#pragma mark Class Methods
+ (BOOL)isReachable {
    return [[[NTLReachabilityManager sharedManager] reachability] isReachable];
}

+ (BOOL)isUnreachable {
    return ![[[NTLReachabilityManager sharedManager] reachability] isReachable];
}

+ (BOOL)isReachableViaWWAN {
    return [[[NTLReachabilityManager sharedManager] reachability] isReachableViaWWAN];
}

+ (BOOL)isReachableViaWiFi {
    return [[[NTLReachabilityManager sharedManager] reachability] isReachableViaWiFi];
}

#pragma mark -
#pragma mark Private Initialization
- (id)init {
    self = [super init];
    
    if (self) {
        // Initialize Reachability
        //self.reachability = [Reachability reachabilityWithHostname:URL_BASE];//@"www.google.com"
        self.reachability = [Reachability reachabilityForInternetConnection];
        
        self.reachability.reachableBlock = ^(Reachability *reachability) {
            NSLog(@"Network is reachable.");
            
        };
        
        self.reachability.unreachableBlock = ^(Reachability *reachability) {
            NSLog(@"Network is unreachable.");
        };
        
        // Start Monitoring
        [self.reachability startNotifier];
    }
    
    return self;
}

@end
